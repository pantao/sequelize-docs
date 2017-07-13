# 原始查询

有的时候，你会发现，直接执行原始的SQL语句会比使用Sequelize ORM更简单，这个时候，你只需要使用 `sequelize.query` 即可。

默认的，函数会返回两个参数，一个是查询结果数据集，另一个是描述信息（比如受影响的列等），但是因为这是原始查询，所以返回的描述信息可能并不能保证在所有的数据库系统中都是一样的，但是不管如何，这两个参数总是会一并返回的。比如：

```javascript
sequelize.query("UPDATE users SET y = 42 WHERE x = 12").spread((results, metadata) => {
  // Results will be an empty array and metadata will contain the number of affected rows.
})
```

如果你并不需要得到描述信息，那么你可以手工的告诉 Sequelize你现在执行的何种类型的查询，比如：

```javascript
sequelize.query("SELECT * FROM `users`", { type: sequelize.QueryTypes.SELECT})
  .then(users => {
    // We don't need spread here, since only the results will be returned for select queries
  })
```

查看[原始码](https://github.com/sequelize/sequelize/blob/master/lib/query-types.js) 已了解更多详情

如果你在第二个参数中设置了一个 `model`，那么查询结果会自动的初始化为该模型的实例：

```javascript
// Callee is the model definition. This allows you to easily map a query to a predefined model
sequelize.query('SELECT * FROM projects', { model: Projects }).then(projects => {
  // Each record will now be a instance of Project
})

```

## 替换

在一个原始查询中，你也可以使用参数替换功能，Sequelize支持两种方式：

1. 使用 `?` 表示替换位，然后使用在 `replacements` 参数数组中按顺序设置要替换的值；
2. 使用 `:key` 表示替换位，然后在 `replacements` 参数对象中使用键值对指定。

```javascript
sequelize.query('SELECT * FROM projects WHERE status = ?',
  { replacements: ['active'], type: sequelize.QueryTypes.SELECT }
).then(projects => {
  console.log(projects)
})

sequelize.query('SELECT * FROM projects WHERE status = :status ',
  { replacements: { status: 'active' }, type: sequelize.QueryTypes.SELECT }
).then(projects => {
  console.log(projects)
})
```

数组替换也会被自动的处理好：

```javascripts
sequelize.query('SELECT * FROM projects WHERE status IN(:status) ',
  { replacements: { status: ['active', 'inactive'] }, type: sequelize.QueryTypes.SELECT }
).then(projects => {
  console.log(projects)
})
```

如果要使用 `%` 符，请在要替换的值上加上：

```javascript
sequelize.query('SELECT * FROM users WHERE name LIKE :search_name ',
  { replacements: { search_name: 'ben%'  }, type: sequelize.QueryTypes.SELECT }
).then(projects => {
  console.log(projects)
})
```

## 参数绑定

Bind parameters are like replacements. Except replacements are escaped and inserted into the query by sequelize before the query is sent to the database, while bind parameters are sent to the database outside the SQL query text. A query can have either bind parameters or replacements.

Only SQLite and PostgreSQL support bind parameters. Other dialects will insert them into the SQL query in the same way it is done for replacements. Bind parameters are referred to by either $1, $2, ... (numeric) or $key (alpha-numeric). This is independent of the dialect.

- If an array is passed, `$1` is bound to the 1st element in the array (`bind[0]`)
- If an object is passed, `$key` is bound to `object['key']`. Each key must begin with a non-numeric char. `$1` is not a valid key, even if object['1'] exists.
- In either case `$$` can be used to escape a literal `$` sign.

The array or object must contain all bound values or Sequelize will throw an exception. This applies even to cases in which the database may ignore the bound parameter.

The database may add further restrictions to this. Bind parameters cannot be SQL keywords, nor table or column names. They are also ignored in quoted text or data. In PostgreSQL it may also be needed to typecast them, if the type cannot be inferred from the context `$1::varchar`.

```javascript
sequelize.query('SELECT *, "text with literal $$1 and literal $$status" as t FROM projects WHERE status = $1',
  { bind: ['active'], type: sequelize.QueryTypes.SELECT }
).then(projects => {
  console.log(projects)
})

sequelize.query('SELECT *, "text with literal $$1 and literal $$status" as t FROM projects WHERE status = $status',
  { bind: { status: 'active' }, type: sequelize.QueryTypes.SELECT }
).then(projects => {
  console.log(projects)
})
```
