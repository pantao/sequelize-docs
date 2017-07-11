# 快速入门

## 安装

**Sequelize** 可以通过 *NPM* 或者 *Yarn* 直接安装：

### 使用 NPM 安装

```bash
// 安装 sequelize
npm install --save sequelize

// 安装以下的任何一种
npm install --save pg pg-hstore
npm install --save mysql2
npm install --save sqlite3
npm install --save tedious
```

### 使用 Yarn 安装

```bash
// 安装 sequelize
yarn add sequlize

// 安装以下的任何一种
yarn add pg pg-hstore
yarn add mysql2
yarn add sqlite3
yarn add tedious
```

## 设置一个连接

Sequelize 会在初始化时，配置一个连接池，所以，如果你只从单进程中连接数据库，理想情况下，最好是一个数据库只对应一个实例。但如果你需要从多个进程中连接数据库，那么最好为每一个进程创建一个连接实例，由于每一个实例都有最大连接数限制，如果 3 个进程需要有90个连接的话，那么每一个实例的最大连接数限制为至少 30.

```javascript
const sequelize = new Sequelize('database', 'username', 'password', {
  host: 'localhsot',
  dialect: 'mysql',  // or 'sqlite' , 'postgres' , 'mssql'

  pool: {
    max: 5,
    min: 0,
    idle: 10000
  },

  // SQLite only
  storage: 'path/to/database.sqlite'
})

// 或者你也可以使用更简单的连接URI地址：
const sequelize = new Sequelize('postgress://user:pass@example.com:5432/dbname')
```

更多详细的设置选项，你可以查看 [API 文档](http://docs.sequelizejs.com/class/lib/sequelize.js~Sequelize.html)

## 测试连接

你可以使用 `.authenticate()` 函数测试连接是否正确。

```javascript
sequelize
  .authenticate()
  .then(() => {
    console.log('连接已创建成功。')
  })
  .catch(error => {
    console.error('连接数据库失败：', error)
  })
```

## 创建第一个模型

模型通过 `sequelize.define('name', { ...attributes }, { ...options })` 定义。

```javascript
const User = sequlieze.define('user', {
  firstName: {
    type: Sequelize.STRING
  },
  lastName: {
    type: Sequelize.STRING
  }
})

// 如果设置 force 为 `true`，则会强制删除已经成功的同名数据表
User.sync({force: true})
  .then(() => {
    // 数据表已创建
    return User.create({
      firstName: '韬',
      lastName: '潘'
    })
  })
```

在 [API 文档](http://docs.sequelizejs.com/class/lib/model.js~Model.html) 中，你可以查看更多关于创建模型的说明。

### 第一个查询

```javascript
User.findAll().then(users => {
  console.log(users)
})
```

在 [查询](querying.md) 章节，你可以查看更多详细内容。

## 应用级模型选项

Sequelize 构造函数中的，接受一个名为 `define` 的参数，该参数定义的字段会在所有已创建的模型中默认启用。

```javascript
const sequelize = new Sequelize('connectionUri', {
  define: {
    timestamps: false // 默认为 true
  }
})

const User = sequelize.define('user', {})
const Post = sequelize.define('post, {
  timestamps: true // 现在 post 模型将有 timestamps
})
```

## 承诺（Promise）

Sequelize 使用 Promise 控制异步控制流，如果你对 Promise 还不太了解，可以通过 [这里](https://github.com/wbinnssmith/awesome-promises) 以及 [这里](http://bluebirdjs.com/docs/why-promises.html) 了解它。

简单来讲，一个Promise就是再向你承诺 —— “我会在有结果的时候，准时告诉你，或者在有错误发生的时候，告诉你发生了什么错误”。

```javascript
// 不要像下面这样
const user = User.findOne()

console.log(user.get('firstName'))
```

*上面这样的代码是完全不会成功执行的*， 因为， `user` 是一个 `promise object`，并不是一个从数据库中查询出来的数据对象，正确的方法是下面这样的：

```javascript
User.findOne().then(user => {
  console.log(user.get('firstName'))
})
```

如果你的运行环境支持 `async` 和 `await`，那么，在一个 `async` 函数中，下面这样也是可以正常执行的：

```javascript
user = await User.findOne()
console.log(user.get('firstName'))
```

在你了解了什么是 Promise 之后，推荐你从 [bluebird API 接口文档](http://bluebirdjs.com/docs/api-reference.html) 去了解更多知识。