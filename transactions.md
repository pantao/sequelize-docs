# 事务 
Sequelize 支持两种方式去使用事务：

1. 基于承诺链的结果，自动提交或者回滚事务，（如果启用）同时将事务传递给回调函数中的所有调用；
2. 将提交、回滚事务的工作交给用户。

这两者的主要区别在于一个使用一个回调，而另一个则直接返回一个承诺。

## 受管理的事务

受管理的事务将自动处理事务的提交与回滚，你可以通过将一个回调函数传递给 `sequelize.transaction` 来创建受管理的事务。

注意下面的代码，是如何向 `sequelize.transaction` 方法传递参数的，我们并没有调用 `t.commit()` 或者 `t.rollback()`，但是，只要所有的承诺都成功，那么 `transaction` 将会自动的 `commit`，否则，将 `rollback`：

```javascript
return sequelize.transaction(function (t) {

  // chain all your queries here. make sure you return them.
  return User.create({
    firstName: 'Abraham',
    lastName: 'Lincoln'
  }, {transaction: t}).then(function (user) {
    return user.setShooter({
      firstName: 'John',
      lastName: 'Boothe'
    }, {transaction: t});
  });

}).then(function (result) {
  // Transaction has been committed
  // result is whatever the result of the promise chain returned to the transaction callback
}).catch(function (err) {
  // Transaction has been rolled back
  // err is whatever rejected the promise chain returned to the transaction callback
});
```

### 在 `rollback` 中抛出错误

当我们使用受管理的事务时，你将永远不需要 `commit` 或者  `rollback`，如果所有的查询都成功的，而你还是想着要回滚的话（比如校验错误），你需要抛出一些异常来 `reject` 承诺链即可。

```javascript
return sequelize.transaction(function (t) {
  return User.create({
    firstName: 'Abraham',
    lastName: 'Lincoln'
  }, {transaction: t}).then(function (user) {
    // Woops, the query was successful but we still want to roll back!
    throw new Error();
  });
});
```

### 自动将 `transaction` 传递给所有的查询

上面的示例中，你可以看到，我们还是需要手工的通过` { transaction: t}` 手工的将事务传递给每一个查询，要让事务的传递自动化，我们还需要使用一个名为 [continuation local storage(CLS)](https://github.com/othiym23/node-continuation-local-storage) 的工具，它将为你的代码创建一个命名空间。

```javascript
const cls = req uire('continuation-local-storage')
const namespace = cls.createNamespace('my-very-own-namespace')
```

要启用 CLS，你必须明确的告诉 Sequelize 你将使用哪一个命名空间。

```javascript
const Sequelize = require('sequelize');
Sequelize.useCLS(namespace);

new Sequelize(....);
```

注意，`useCLS()` 方法是执行在 *构造器* 上面的，并不是在实例上执行的，这表示，你所有的实例都将使用同一个命名空间，这也表明，你所有的实例要么都有同一个命名空间，要么都没有命名空间，我们不能单独为某一个实例启用或者信用命名空间。

CLS 就像对于 `callbacks` 的 `thread-local-storage` 的工作原理一样，这表示，在不同的回调链中，我们都可以访问到同一个本地变量。当 `CLS` 启用之后，Sequelize 人在一个新的事务创建之后，在命名空间中设置一个 `transaction` 属性，由于回调链是私有的，所有可以支持同时存在多个事务。

```javascript
sequelize.transaction(function (t1) {
  namespace.get('transaction') === t1; // true
});

sequelize.transaction(function (t2) {
  namespace.get('transaction') === t2; // true
});
```

绝大多数情况下，你并不需要直接访问 `namespace.get('transaction')` ，所有的查询都会自动的从命名空间中去获取事务。

```javascript
sequelize.transaction(function (t1) {
  // With CLS enabled, the user will be created inside the transaction
  return User.create({ name: 'Alice' });
});
```

当你启用了 `Sequelize.useCLS()` 之后，所有的承诺都会被打开补丁，以维持CLS的上下文关系，CLS是一个相对比较复杂的概念，要了解得更加透彻，可以查看 [cls-blurbird](https://www.npmjs.com/package/cls-bluebird)。

 ## 并发、部分事务

你可以在一系列查询中执行并发事务，或者将某些事务从一个事务中排除，使用 `{transaction: }` 选项来控制查询所属的事务：

### 不启用 CLS

```javascript
sequelize.transaction(function (t1) {
  return sequelize.transaction(function (t2) {
    // With CLS enable, queries here will by default use t2
    // Pass in the `transaction` option to define/alter the transaction they belong to.
    return Promise.all([
        User.create({ name: 'Bob' }, { transaction: null }),
        User.create({ name: 'Mallory' }, { transaction: t1 }),
        User.create({ name: 'John' }) // this would default to t2
    ]);
  });
});
```

## 隔离等级

你可以为事务设置不同的隔离等级：

```javascript
Sequelize.Transaction.ISOLATION_LEVELS.READ_UNCOMMITTED // "READ UNCOMMITTED"
Sequelize.Transaction.ISOLATION_LEVELS.READ_COMMITTED // "READ COMMITTED"
Sequelize.Transaction.ISOLATION_LEVELS.REPEATABLE_READ  // "REPEATABLE READ"
Sequelize.Transaction.ISOLATION_LEVELS.SERIALIZABLE // "SERIALIZABLE"
```

Sequelize 默认使用 `REPEATABLE READ` 等级，如果你想使用其它不同的等级的话，可以通过下面这样的方式设置：

```javascript
return sequelize.transaction({
  isolationLevel: Sequelize.Transaction.ISOLATION_LEVELS.SERIALIZABLE
  }, function (t) {

  // your transactions

  });
```

## 未受控的事务（`then-callback`）

未受控的事务需要你完全手工的提交或者回滚事务，如果你未触发这些操作，那么整个过程将一直挂起，直到超时，要开始一个未受控事务，可以直接调用 `sequelize.transaction()` 即可，不需要传递任何回调函数。

```javascript
return sequelize.transaction().then(function (t) {
  return User.create({
    firstName: 'Homer',
    lastName: 'Simpson'
  }, {transaction: t}).then(function (user) {
    return user.addSibling({
      firstName: 'Lisa',
      lastName: 'Simpson'
    }, {transaction: t});
  }).then(function () {
    return t.commit();
  }).catch(function (err) {
    return t.rollback();
  });
});
```

### 选项

`transaction` 方法接受一个 `option` 对象。

```javascript
return sequelize.transaction({ /* options */ });
```

下面的表示的是默认的参数：

```javascript
{
  autocommit: true,
  isolationLevel: 'REPEATABLE_READ',
  deferrable: 'NOT DEFERRABLE' // implicit default of postgres
}
```

`isolationLevel` 可以直接在全局进行设置：

```javascript
// globally
new Sequelize('db', 'user', 'pw', {
  isolationLevel: Sequelize.Transaction.ISOLATION_LEVELS.SERIALIZABLE
});

// locally
sequelize.transaction({
  isolationLevel: Sequelize.Transaction.ISOLATION_LEVELS.SERIALIZABLE
});
```

`deferrable` 选项会触发一个额外的查询，以检测约束检测是立即执行还是延迟执行，但是该功能仅在 PostgreSQL 上受支持。

```javascript
sequelize.transaction({
  // to defer all constraints:
  deferrable: Sequelize.Deferrable.SET_DEFERRED,

  // to defer a specific constraint:
  deferrable: Sequelize.Deferrable.SET_DEFERRED(['some_constraint']),

  // to not defer constraints:
  deferrable: Sequelize.Deferrable.SET_IMMEDIATE
})
```

## 与其它 Sequelize 方法一起使用

`transaction` 通常都是第一个参数，但是对于那些需要传递数据的方法，比如 `create`、`update`、`updateAttributes` 等，第一个参数通常都是值，而仅接着的就是 `transaction`。

