# 钩子

钩子（也被人称之为回调链或者生命周期事件），本质就是一些函数，他们会在某个事件发生前或者后执行，比如，如果你想一个模型在保存数据之前都设置一个值，那么可以使用 `beforeUpdate` 钩子。

## 生命周期

```text
(1)
  beforeBulkCreate(instances, options)
  beforeBulkDestroy(options)
  beforeBulkUpdate(options)
(2)
  beforeValidate(instance, options)
(-)
  validate
(3)
  afterValidate(instance, options)
  - or -
  validationFailed(instance, options, error)
(4)
  beforeCreate(instance, options)
  beforeDestroy(instance, options)
  beforeUpdate(instance, options)
  beforeSave(instance, options)
  beforeUpsert(values, options)
(-)
  create
  destroy
  update
(5)
  afterCreate(instance, options)
  afterDestroy(instance, options)
  afterUpdate(instance, options)
  afterSave(instance, options)
  afterUpsert(created, options)
(6)
  afterBulkCreate(instances, options)
  afterBulkDestroy(options)
  afterBulkUpdate(options)
```

## 声明钩子

传递给钩子的都是参数的引用，这表示，你在钩子函数内对数据的修改都将直接反应至实例本身，可以通过返回一个承诺以创建异步钩子：

```javascript
// Method 1 via the .define() method
const User = sequelize.define('user', {
  username: DataTypes.STRING,
  mood: {
    type: DataTypes.ENUM,
    values: ['happy', 'sad', 'neutral']
  }
}, {
  hooks: {
    beforeValidate: (user, options) => {
      user.mood = 'happy';
    },
    afterValidate: (user, options) => {
      user.username = 'Toni';
    }
  }
});

// Method 2 via the .hook() method
User.hook('beforeValidate', (user, options) => {
  user.mood = 'happy';
});

User.hook('afterValidate', (user, options) => {
  return sequelize.Promise.reject(new Error("I'm afraid I can't let you do that!"));
});

// Method 3 via the direct method
User.beforeCreate((user, options) => {
  return hashPassword(user.password).then(hashedPw => {
    user.password = hashedPw;
  });
});

User.afterValidate('myHookAfter', (user, options) => {
  user.username = 'Toni';
});
```

## 移除钩子

只有定义了名称的钩子才能被移除：

```javascript
const Book = sequelize.define('book', {
  title: DataTypes.STRING
});

Book.addHook('afterCreate', 'notifyUsers', (book, options) => {
  // ...
});

Book.removeHook('afterCreate', 'notifyUsers');
```

## 全局钩子

影响所有模型的钩子称之为全局钩子，他们可以被用来定义一些你希望在某个时候所有模型都执行的一些行为。

### Sequelize.options.define(DefaultHook)

```javascript
const sequelize = new Sequelize(..., {
    define: {
        hooks: {
            beforeCreate: () => {
                // Do stuff
            }
        }
    }
});
```

这将会添加一个默认的 `beforeCreate` 钩子，如果某个模型没有定义自己本地的 `beforeCreate` 钩子的话，那么该钩子将会被执行：

```javascript
const User = sequelize.define('user');
const Project = sequelize.define('project', {}, {
    hooks: {
        beforeCreate: () => {
            // Do other stuff
        }
    }
});

User.create() // Runs the global hook
Project.create() // Runs its own hook (because the global hook is overwritten)
```

### Sequelize.addHook(PermanentHook)

添加常驻钩子：

```javascript
sequelize.addHook('beforeCreate', () => {
    // Do stuff
});
```

这个钩子不管模型是否定义了本地的 `beforeCreate` 钩子，它都会执行。

```javascript
const User = sequelize.define('user');
const Project = sequelize.define('project', {}, {
    hooks: {
        beforeCreate: () => {
            // Do other stuff
        }
    }
});

User.create() // Runs the global hook
Project.create() // Runs its own hook, followed by the global hook
```

## 实例钩子

下面这些钩子会在你编辑单个对象时被调用：

```text
beforeValidate
afterValidate or validationFailed
beforeCreate / beforeUpdate  / beforeDestroy
afterCreate / afterUpdate / afterDestroy
```

```javascript
// ...define ...
User.beforeCreate(user => {
  if (user.accessLevel > 10 && user.username !== "Boss") {
    throw new Error("You can't grant this user an access level above 10!")
  }
})
```

下面这个示例将会触发一个错误：

```javascript
User.create({username: 'Not a Boss', accessLevel: 20}).catch(err => {
  console.log(err); // You can't grant this user an access level above 10!
});
```

下面的示例则会成功：

```javascript
User.create({username: 'Boss', accessLevel: 20}).then(user => {
  console.log(user); // user object with username as Boss and accessLevel of 20
});
```

## 棤型钩子

有些时候，我们可能会同一时间对多个实例进行操作，比如 `bulkCreate`、`update`、`destroy` 等，此时你可以使用下面这些钩子：

```text
beforeBulkCreate / beforeBulkUpdate / beforeBulkDestroy
afterBulkCreate / afterBulkUpdate / afterBulkDestroy
```

如果你希望在批量操作中，每次都对单个记录单独触发钩子的话，可以使用 `indivdualHooks: true` 选项。

```javascript
Model.destroy({ where: {accessLevel: 0}, individualHooks: true});
// Will select all records that are about to be deleted and emit before- + after- Destroy on each instance

Model.update({username: 'Toni'}, { where: {accessLevel: 0}, individualHooks: true});
// Will select all records that are about to be updated and emit before- + after- Update on each instance
```

有些模型钩子可以接受两个或者三个参数：

```javascript
Model.beforeBulkCreate((records, fields) => {
  // records = the first argument sent to .bulkCreate
  // fields = the second argument sent to .bulkCreate
})

Model.bulkCreate([
  {username: 'Toni'}, // part of records argument
  {username: 'Tobi'} // part of records argument
], ['username'] /* part of fields argument */)

Model.beforeBulkUpdate((attributes, where) => {
  // attributes = first argument sent to Model.update
  // where = second argument sent to Model.update
})

Model.update({gender: 'Male'} /*attributes argument*/, { where: {username: 'Tom'}} /*where argument*/)

Model.beforeBulkDestroy(whereClause => {
  // whereClause = first argument sent to Model.destroy
})

Model.destroy({ where: {username: 'Tom'}} /*whereClause argument*/)
```

如果你在使用 `Model.bulkCreate(...)` 时使用了 `updatesOnDuplicate` 选项，则该选项中未指定的字段将不会被更新，但是，你还是可以在钩子内动态的更新 `updatesOnDuplicate` 选项的值：

```javascript
// Bulk updating existing users with updatesOnDuplicate option
Users.bulkCreate([
  { id: 1, isMemeber: true },
  { id: 2, isMember: false }
], {
  updatesOnDuplicate: ['isMember']
});

User.beforeBulkCreate((users, options) => {
  for (const user of users) {
    if (user.isMember) {
      user.memberSince = new Date();
    }
  }

  // Add memberSince to updatesOnDuplicate otherwise the memberSince date wont be
  // saved to the database
  options.updatesOnDuplicate.push('memberSince');
});
```

## 关联

绝多数钩子都会在关联对象上像普通对象一样执行：

1. 当使用 `add/set` 函数时，`beforeUpdate/afterUpdate` 钩子会执行；
2. 唯一一个呼起 `beforeDestroy/afterDestroy` 钩子的方式只有 `onDelete: 'cascade` 以及 `hooks: true`：

```javascript
const Projects = sequelize.define('projects', {
  title: DataTypes.STRING
});

const Tasks = sequelize.define('tasks', {
  title: DataTypes.STRING
});

Projects.hasMany(Tasks, { onDelete: 'cascade', hooks: true });
Tasks.belongsTo(Projects);
```

上面的代码片段会在 `Tasks` 上执行，当执行级联删除时，Sequelize会简单的执行下面这个SQL：

```sql
DELETE FROM `table` WHERE associatedIdentifier = associatedIdentifier.primaryKey
```

设置 `hooks: true` 是为了告诉Sequelize，优化是不需要你关心的事情，你只需要一个一个的删除关联的实例即可，只有这样才能保证正确的调用钩子函数。

如果你在关联关系是 `n:m`，那么你可有会需要在删除两个实例之后也删除 `through` 实例，Sequelize 使用的是 `Model.destroy` 去调用 `bulkDestroy` ，而不是使用实例上的 `before/afterDestroy` 钩子。

如果你想为每一个实例单独调用钩子的话，只要在删除时，设置  `individualHooks: true` 即可。

## 事务相关的一些注意事项

很多Sequelize操作都允许你在操作后面指定一个事务对象，如果你在原始调用指定了一个事务，那么该事务将出现在传递给 Hook 函数的 `options` 参数中。

```javascript
// Here we use the promise-style of async hooks rather than
// the callback.
User.hook('afterCreate', (user, options) => {
  // 'transaction' will be available in options.transaction

  // This operation will be part of the same transaction as the
  // original User.create call.
  return User.update({
    mood: 'sad'
  }, {
    where: {
      id: user.id
    },
    transaction: options.transaction
  });
});

sequelize.transaction(transaction => {
  User.create({
    username: 'someguy',
    mood: 'happy',
    transaction
  });
});
```

如果我们在上述代码片段中的 `User.update` 调用中没有包含 `transaction` 选项，那么在新创建的用户过程中，并不会产生我们所预想的结果，因为新创建的用户在挂起事务提交之前，数据并不存在数据库中。

## 内部事务

像 `Model.findOrCreate` 这样的操作，Sequelize 内部其实是创建了一个事务去进行这个操作的， 如果你的钩子函数执行依赖于对数据库的读取或写入，或者像上一节中示例的那样修改存储的值，那么，你应该永远都传递 `{ transaction: options.transaction }` 值。

如果在一个已经事务化的操作中调用了一个钩子，这会保证你依赖的 `read/write` 操作会处于同一个事务中，如果钩子未事务化，那么你只需要简单的定义 `{ transaction: null }` 即可。