# 模型使用

## 数据检索/查找

数据查找方法用于从数据库中查找数据，它们**不返回**纯对象，而是返回模型的实例，由此，你可以在返回的对象上调用任何模型支持的方法。

在本文中，我们将探索查找方法可以帮你做什么。

### `find` —— 从数据库中查找一条记录

```javascript
// search for known ids
Project.findById(123).then(project => {
  // project will be an instance of Project and stores the content of the table entry
  // with id 123. if such an entry is not defined you will get null
})

// search for attributes
Project.findOne({ where: {title: 'aProject'} }).then(project => {
  // project will be the first entry of the Projects table with the title 'aProject' || null
})


Project.findOne({
  where: {title: 'aProject'},
  attributes: ['id', ['name', 'title']]
}).then(project => {
  // project will be the first entry of the Projects table with the title 'aProject' || null
  // project.title will contain the name of the project
})
```

### `findOrCreate` —— 查找一条记录，如果不存在，则创建之

该方法与 `find` 类似，唯一的不同是，当未找到任何数据时，它会创建一条符合条件的记录。

现在假设我们有一个空的数据库以及一个模型 `User`，它具有两个属性，分别为 `username` 和 `job`：

```javascript
User
  .findOrCreate({where: {username: 'sdepold'}, defaults: {job: 'Technical Lead JavaScript'}})
  .spread((user, created) => {
    console.log(user.get({
      plain: true
    }))
    console.log(created)

    /*
     findOrCreate returns an array containing the object that was found or created and a boolean that will be true if a new object was created and false if not, like so:

    [ {
        username: 'sdepold',
        job: 'Technical Lead JavaScript',
        id: 1,
        createdAt: Fri Mar 22 2013 21: 28: 34 GMT + 0100(CET),
        updatedAt: Fri Mar 22 2013 21: 28: 34 GMT + 0100(CET)
      },
      true ]

 In the example above, the "spread" on line 39 divides the array into its 2 parts and passes them as arguments to the callback function defined beginning at line 39, which treats them as "user" and "created" in this case. (So "user" will be the object from index 0 of the returned array and "created" will equal "true".)
    */
  })
```

下面的代码则会先创建一个对象，而且因为该实例已经存在了，所以在 `findOrCreate` 方法中， `created` 将为 `false` 了。

```javascript
User.create({ username: 'fnord', job: 'omnomnom' })
  .then(() => User.findOrCreate({where: {username: 'fnord'}, defaults: {job: 'something else'}}))
  .spread((user, created) => {
    console.log(user.get({
      plain: true
    }))
    console.log(created)

    /*
    In this example, findOrCreate returns an array like this:
    [ {
        username: 'fnord',
        job: 'omnomnom',
        id: 2,
        createdAt: Fri Mar 22 2013 21: 28: 34 GMT + 0100(CET),
        updatedAt: Fri Mar 22 2013 21: 28: 34 GMT + 0100(CET)
      },
      false
    ]
    The array returned by findOrCreate gets spread into its 2 parts by the "spread" on line 69, and the parts will be passed as 2 arguments to the callback function beginning on line 69, which will then treat them as "user" and "created" in this case. (So "user" will be the object from index 0 of the returned array and "created" will equal "false".)
    */
  })
```

### `findAndCountAll` 搜索多条记录，同时返回所有数据以及总数据量的统计

这是一个复合型方法，它结合了 `findAll` 与 `count` 两个方法，该方法会返回一个包含两个属性的对象，这两个属性分别是：

- `count` —— 一个整型数字，表示满足当前查询条件的总记录数量；
- `rows` —— 一个包含查询结果的模型实例的数组

```javascript
Project
  .findAndCountAll({
    where: {
        title: {
          $like: 'foo%'
        }
    },
    offset: 10,
    limit: 2
  })
  .then(result => {
    console.log(result.count);
    console.log(result.rows);
  });
```

`findAndCountAll` 同样支持 `includes`，但只有当 `includes` 被标记为 `required` 的时候，才会影响到统计结果。

比如，假设你现在想要查询所有的已经添加了个人Profile数据的用户：

```javascript
User.findAndCountAll({
  include: [
     { model: Profile, required: true}
  ],
  limit: 3
});
```

因为 `Profile` 的 `required` 设置为 `true`，所以，只有设置了个人 Profile 数据的用户才会被统计，如果我们移除 `required` 这个属性，那么不管用户是否添加了 Profile，都会被统计进去。如果我们对 `includes` 中添加 `where` 属性，则会自动的设置 `required` 为 `true`。

```javascript
User.findAndCountAll({
  include: [
     { model: Profile, where: { active: true }}
  ],
  limit: 3
});
```

上面的代码片段，将仅会统计存在已激活了Profile资料的用户，因为 `required` 已经被隐性的设置为 `true`。

`findAndCountAll` 的 `options` 与 `findAll` 一样。

### `findAll` —— 查找所有符合要求的记录

```javascript
// find multiple entries
Project.findAll().then(projects => {
  // projects will be an array of all Project instances
})

// also possible:
Project.all().then(projects => {
  // projects will be an array of all Project instances
})

// search for specific attributes - hash usage
Project.findAll({ where: { name: 'A Project' } }).then(projects => {
  // projects will be an array of Project instances with the specified name
})

// search within a specific range
Project.findAll({ where: { id: [1,2,3] } }).then(projects => {
  // projects will be an array of Projects having the id 1, 2 or 3
  // this is actually doing an IN query
})

Project.findAll({
  where: {
    id: {
      $and: {a: 5}           // AND (a = 5)
      $or: [{a: 5}, {a: 6}]  // (a = 5 OR a = 6)
      $gt: 6,                // id > 6
      $gte: 6,               // id >= 6
      $lt: 10,               // id < 10
      $lte: 10,              // id <= 10
      $ne: 20,               // id != 20
      $between: [6, 10],     // BETWEEN 6 AND 10
      $notBetween: [11, 15], // NOT BETWEEN 11 AND 15
      $in: [1, 2],           // IN [1, 2]
      $notIn: [1, 2],        // NOT IN [1, 2]
      $like: '%hat',         // LIKE '%hat'
      $notLike: '%hat'       // NOT LIKE '%hat'
      $iLike: '%hat'         // ILIKE '%hat' (case insensitive)  (PG only)
      $notILike: '%hat'      // NOT ILIKE '%hat'  (PG only)
      $overlap: [1, 2]       // && [1, 2] (PG array overlap operator)
      $contains: [1, 2]      // @> [1, 2] (PG array contains operator)
      $contained: [1, 2]     // <@ [1, 2] (PG array contained by operator)
      $any: [2,3]            // ANY ARRAY[2, 3]::INTEGER (PG only)
    },
    status: {
      $not: false,           // status NOT FALSE
    }
  }
})
```

### 复合过滤 AND/OR/NOT

你可以通过 `$or`、`$and` 以及 `$not` 来创建多层级的 `OR`、`AND` 与 `NOT` 查询：

```javascript
Project.findOne({
  where: {
    name: 'a project',
    $or: [
      { id: [1,2,3] },
      { id: { $gt: 10 } }
    ]
  }
})

Project.findOne({
  where: {
    name: 'a project',
    id: {
      $or: [
        [1,2,3],
        { $gt: 10 }
      ]
    }
  }
})
```

