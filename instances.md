# 实例

## 构建非持久性实例

如果你仅仅只是要创建一个已定义了的模型的非持久性实例，如用下面的方法即可，`build` 方法将返回一个未持久化的实例：

```javascript
const project = Project.build({
  title: 'my awesome project',
  description: 'woot woot. this will make me a rich man'
})

const task = Task.build({
  title: 'specify the project idea',
  description: 'bla',
  deadline: new Date()
})
```

如果定义了默认值，在 `build` 时又未指定值，那么 `build` 之后的实例将自动获取默认值：

```javascript
// first define the model
const Task = sequelize.define('task', {
  title: Sequelize.STRING,
  rating: { type: Sequelize.STRING, defaultValue: 3 }
})

// now instantiate an object
const task = Task.build({title: 'very important task'})

task.title  // ==> 'very important task'
task.rating // ==> 3
```

如果要将一个非持久化的实例保存至数据库，直接使用 `save` 方法即可，适当的时候，还需要捕获它的相关事件：

```javascript
project.save().then(() => {
  // my nice callback stuff
})

task.save().catch(error => {
  // mhhh, wth!
})

// you can also build, save and access the object with chaining:
Task
  .build({ title: 'foo', description: 'bar', deadline: new Date() })
  .save()
  .then(anotherTask => {
    // you can now access the currently saved task with the variable anotherTask... nice!
  })
  .catch(error => {
    // Ooops, do some error-handling
  })
```

## 创建持久化的实例

如果你想创建一个持久化至数据库中的实例的话，可以使用 `create` 方法即可：

```javascript
Task.create({ title: 'foo', description: 'bar', deadline: new Date() }).then(task => {
  // you can now access the newly created task via the variable task
})
```

你还可以设定哪些字段是可以在创建的过程中被指定的：

```javascript
User.create({ username: 'barfooz', isAdmin: true }, { fields: [ 'username' ] }).then(user => {
  // let's assume the default of isAdmin is false:
  console.log(user.get({
    plain: true
  })) // => { username: 'barfooz', isAdmin: false }
})
```

## 更新、保存以及持久化更新一个实例

现在我们来看看如何更新一个已持久化的实例，并将修改同步至数据库中：

```javascript
// way 1
task.title = 'a very different title now'
task.save().then(() => {})

// way 2
task.update({
  title: 'a very different title now'
}).then(() => {})
```

与 `create` 一样，你同样还可以指定哪些字段是可以被更新的：

```javascript
task.title = 'foooo'
task.description = 'baaaaaar'
task.save({fields: ['title']}).then(() => {
 // title will now be 'foooo' but description is the very same as before
})

// The equivalent call using update looks like this:
task.update({ title: 'foooo', description: 'baaaaaar'}, {fields: ['title']}).then(() => {
 // title will now be 'foooo' but description is the very same as before
})
```

## 销毁、删除已持久化的实例

当你创建了一个实例，并得到该实例的引用之后，即可使用 `destroy` 方法销毁该实例：

```javascript
Task.create({ title: 'a task' }).then(task => {
  // now you see me...
  return task.destroy();
}).then(() => {
 // now i'm gone :)
})
```

如果 `paranoid` 选项被设置为 `true`，该对象将不会被删除，而是会被添加一个 `deletedAt` 字段，用于表示该条记录何时被删除，如果要强制删除，可以在删除的方法中传递参数 `force` 为 `true`：

```javascript
task.destroy({ force: true })
```

## 指操作（创建、更新、销毁多条记录）

额外的，Sequelize还提供了让你可以进行指操作的方法，它们分别是：

- `Model.bulkCreate`
- `Model.update`
- `Model.destroy`

当你对多条记录进行批量操作时，返回的将不再是一个DAO对象，对于 `Model.bulkCreate` 将会返回所有被成功创建的实例的集合（数组），但不同于 `create` 创建的实例，自增类型的字段将没有值， `update` 与 `destroy` 将会返回所有受影响的记录数量。

先让我们看看 `Model.bulkCreate`：

```javascript
User.bulkCreate([
  { username: 'barfooz', isAdmin: true },
  { username: 'foo', isAdmin: true },
  { username: 'bar', isAdmin: false }
]).then(() => { // Notice: There are no arguments here, as of right now you'll have to...
  return User.findAll();
}).then(users => {
  console.log(users) // ... in order to get the array of user objects
})
```

要批量更新多条记录：

```javascript
Task.bulkCreate([
  {subject: 'programming', status: 'executing'},
  {subject: 'reading', status: 'executing'},
  {subject: 'programming', status: 'finished'}
]).then(() => {
  return Task.update(
    { status: 'inactive' }, /* set attributes' value */,
    { where: { subject: 'programming' }} /* where criteria */
  );
}).spread((affectedCount, affectedRows) => {
  // .update returns two values in an array, therefore we use .spread
  // Notice that affectedRows will only be defined in dialects which support returning: true

  // affectedCount will be 2
  return Task.findAll();
}).then(tasks => {
  console.log(tasks) // the 'programming' tasks will both have a status of 'inactive'
})
```

接着删除他们：

```javascript
Task.bulkCreate([
  {subject: 'programming', status: 'executing'},
  {subject: 'reading', status: 'executing'},
  {subject: 'programming', status: 'finished'}
]).then(() => {
  return Task.destroy({
    where: {
      subject: 'programming'
    },
    truncate: true /* this will ignore where and truncate the table instead */
  });
}).then(affectedRows => {
  // affectedRows will be 2
  return Task.findAll();
}).then(tasks => {
  console.log(tasks) // no programming, just reading :(
})
```

如果你是从其它数据源接收数据，那么，限制被更新的值的字段类型是很有必要的，与 `create` 一样，你可以在 `bulkCreate` 的第二个参数中传递一个对象作为参数，该对象中的 `fields` 值即可表示哪些字段是可以被创建的：

```javascript
User.bulkCreate([
  { username: 'foo' },
  { username: 'bar', admin: true}
], { fields: ['username'] }).then(() => {
  // nope bar, you can't be admin!
})
```

`bulkCreate` 使用的是主流/快速的方法进行多记录的插入，但是有时候你还是希望对模型中的数据进行验证，此时，你同样可以使用 `validate: true`：

```javascript
const Tasks = sequelize.define('task', {
  name: {
    type: Sequelize.STRING,
    validate: {
      notNull: { args: true, msg: 'name cannot be null' }
    }
  },
  code: {
    type: Sequelize.STRING,
    validate: {
      len: [3, 10]
    }
  }
})

Tasks.bulkCreate([
  {name: 'foo', code: '123'},
  {code: '1234'},
  {name: 'bar', code: '1'}
], { validate: true }).catch(errors => {
  /* console.log(errors) would look like:
  [
    { record:
    ...
    errors:
      { name: 'SequelizeValidationError',
        message: 'Validation error',
        errors: [Object] } },
    { record:
      ...
      errors:
        { name: 'SequelizeValidationError',
        message: 'Validation error',
        errors: [Object] } }
  ]
  */
})
```

## 实例的值

如果你打印出一个实例，你会发现很多额外的信息，如果你只想得到一个纯净的实例对象，那么可以使用使用的 `get` 方法：

```javascript
Person.create({
  name: 'Rambow',
  firstname: 'John'
}).then(john => {
  console.log(john.get({
    plain: true
  }))
})

// result:

// { name: 'Rambow',
//   firstname: 'John',
//   id: 1,
//   createdAt: Tue, 01 May 2012 19:12:16 GMT,
//   updatedAt: Tue, 01 May 2012 19:12:16 GMT
// }
```

**小技巧**：你还可以使用 `JSON.stringify(instance)` 得到实例JSON化后的字符串，它也是一个纯净的对象的表示。

## 重载实例

如果你想从数据库中重载实例，可以使用实例的 `reload` 方法：

```javascript
Person.findOne({ where: { name: 'john' } }).then(person => {
  person.name = 'jane'
  console.log(person.name) // 'jane'

  person.reload().then(() => {
    console.log(person.name) // 'john'
  })
})
```

## Incrementing

如果你想在增加某一个值，而避免并发问题，可以使用 `increment` 方法：

```javascript
User.findById(1).then(user => {
  return user.increment('my-integer-field', {by: 2})
}).then(/* ... */)
```

你还可以一次性定义多个字段：

```javascript
User.findById(1).then(user => {
  return user.increment([ 'my-integer-field', 'my-very-other-field' ], {by: 2})
}).then(/* ... */)
```

当然，你还可以定义每一个字段要增加的值：

```javascript
User.findById(1).then(user => {
  return user.increment({
    'my-integer-field':    2,
    'my-very-other-field': 3
  })
}).then(/* ... */)
```

## Decrementing

与 Incrementing 一样：

```javascript
User.findById(1).then(user => {
  return user.decrement('my-integer-field', {by: 2})
}).then(/* ... */)

User.findById(1).then(user => {
  return user.decrement([ 'my-integer-field', 'my-very-other-field' ], {by: 2})
}).then(/* ... */)

User.findById(1).then(user => {
  return user.decrement({
    'my-integer-field':    2,
    'my-very-other-field': 3
  })
}).then(/* ... */)
```