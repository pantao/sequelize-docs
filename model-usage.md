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

上面的两种写法都会生成下面这段SQL语句：

```sql
SELECT *
FROM `Projects`
WHERE (
  `Projects`.`name` = 'a project'
   AND (`Projects`.`id` IN (1,2,3) OR `Projects`.`id` > 10)
)
LIMIT 1;
```

`$not` 示例：

```javascript
Project.findOne({
  where: {
    name: 'a project',
    $not: [
      { id: [1,2,3] },
      { array: { $contains: [3,4,5] } }
    ]
  }
});
```

将会生成：

```sql
SELECT *
FROM `Projects`
WHERE (
  `Projects`.`name` = 'a project'
   AND NOT (`Projects`.`id` IN (1,2,3) OR `Projects`.`array` @> ARRAY[3,4,5]::INTEGER[])
)
LIMIT 1;
```

### 通过 `limit`、`offset`、`order` 以及 `group` 操作数据集

要更加自由的操作数据集，你可以使用 `limit`、`offset`、`order` 以及 `group`：

```javascript
// limit the results of the query
Project.findAll({ limit: 10 })

// step over the first 10 elements
Project.findAll({ offset: 10 })

// step over the first 10 elements, and take 2
Project.findAll({ offset: 10, limit: 2 })
```

`order` 与 `group` 的语法是一样的：

```javascript
// ORDER BY title DESC
Project.findAll({order: 'title DESC'})

// GROUP BY name
Project.findAll({group: 'name'})
```

请注意上面两个例子是如何执行的，参数的字符串值是直接逐字被插入到SQL语句中的，字符是没有被 `escape` 的，如果你需要插入 `escape` 之后的字符，那么请使用数组的方式：

```javascript
something.findOne({
  order: [
    'name',
    // will return `name`
    'username DESC',
    // will return `username DESC` -- i.e. don't do it!
    ['username', 'DESC'],
    // will return `username` DESC
    sequelize.fn('max', sequelize.col('age')),
    // will return max(`age`)
    [sequelize.fn('max', sequelize.col('age')), 'DESC'],
    // will return max(`age`) DESC
    [sequelize.fn('otherfunction', sequelize.col('col1'), 12, 'lalala'), 'DESC'],
    // will return otherfunction(`col1`, 12, 'lalala') DESC
    [sequelize.fn('otherfunction', sequelize.fn('awesomefunction', sequelize.col('col'))), 'DESC']
    // will return otherfunction(awesomefunction(`col`)) DESC, This nesting is potentially infinite!
  ]
})
```

概括来讲， `order/group` 数组的元素是下面这样的规则：

- 字符（String） —— 会被 ``` 号标记；
- 数组（Array）—— 第一个元素字符会被 ``` 标记，第二个会直接插入；
- 对象（Object）
    - 原始对象将会被直接插入
    - 任何其它对象都会被直接忽略，同时，查询失败
- `Sequelize.fn` 与 `Sequelize.col` 返回函数以及被 ``` 标记的参数

### 原始查询

有些时候，可能你可能会查询一个很大的数据集，而你仅仅只是需要展示而已，此时你并不需要更新、删除等操作，那么，你可以使用原始查询，这会大大减少系统的执行效率，它仅仅只会返回原始的查询结果，而不去为结果集中的每一条数据初始化为一个模型的实例。

```javascript
// Are you expecting a massive dataset from the DB,
// and don't want to spend the time building DAOs for each entry?
// You can pass an extra query option to get the raw data instead:
Project.findAll({ where: { ... }, raw: true })
```

### `count` —— 统计某一个查询结果集的数据条数

```javascript
Project.count().then(c =>
  console.log("There are " + c + " projects!")
})

Project.count({ where: {'id': {$gt: 25}} }).then(c =>
  console.log("There are " + c + " projects with an id greater than 25.")
})
```

### `max` —— 获取数据表中某一个字段的最大值

```javascript
/*
  Let's assume 3 person objects with an attribute age.
  The first one is 10 years old,
  the second one is 5 years old,
  the third one is 40 years old.
*/
Project.max('age').then(max => {
  // this will return 40
})

Project.max('age', { where: { age: { lt: 20 } } }).then(max => {
  // will be 10
})
```

### `min` —— 获取某个字段的最小值

```javascript
/*
  Let's assume 3 person objects with an attribute age.
  The first one is 10 years old,
  the second one is 5 years old,
  the third one is 40 years old.
*/
Project.min('age').then(min => {
  // this will return 5
})

Project.min('age', { where: { age: { $gt: 5 } } }).then(min => {
  // will be 10
})
```

### `sum` —— 求特定字段所有值的总和

```javascript
/*
  Let's assume 3 person objects with an attribute age.
  The first one is 10 years old,
  the second one is 5 years old,
  the third one is 40 years old.
*/
Project.sum('age').then(sum => {
  // this will return 55
})

Project.sum('age', { where: { age: { $gt: 5 } } }).then(sum => {
  // will be 50
})
```

### Eager loading

当你需要从数据库中查询某一个模型的数据，同时还想在同一个查询中加载该模型相关联的数据时，你就会用到 Eager loading 功能，最简单的方法，就是在你使用 `find` 或者 `findAll` 的时候，使用 `include` 功能：

```javascript
const User = sequelize.define('user', { name: Sequelize.STRING })
const Task = sequelize.define('task', { name: Sequelize.STRING })
const Tool = sequelize.define('tool', { name: Sequelize.STRING })

Task.belongsTo(User)
User.hasMany(Task)
User.hasMany(Tool, { as: 'Instruments' })

sequelize.sync().then(() => {
  // this is where we continue ...
})
```

现在让我们先加载所有的 `tasks` ，同时还要加载出每一条 `task` 的所属用户：

```javascript
Task.findAll({ include: [ User ] }).then(tasks => {
  console.log(JSON.stringify(tasks))

  /*
    [{
      "name": "A Task",
      "id": 1,
      "createdAt": "2013-03-20T20:31:40.000Z",
      "updatedAt": "2013-03-20T20:31:40.000Z",
      "userId": 1,
      "user": {
        "name": "John Doe",
        "id": 1,
        "createdAt": "2013-03-20T20:31:45.000Z",
        "updatedAt": "2013-03-20T20:31:45.000Z"
      }
    }]
  */
})
```

请注意，结果集中的用户是单数的一个对象，那是因为我们使用的关联方式就是 `one-to-something`。

接下来，让我们加载 `many-to-something` 关联：

```javascript
User.findAll({ include: [ Task ] }).then(users => {
  console.log(JSON.stringify(users))

  /*
    [{
      "name": "John Doe",
      "id": 1,
      "createdAt": "2013-03-20T20:31:45.000Z",
      "updatedAt": "2013-03-20T20:31:45.000Z",
      "tasks": [{
        "name": "A Task",
        "id": 1,
        "createdAt": "2013-03-20T20:31:40.000Z",
        "updatedAt": "2013-03-20T20:31:40.000Z",
        "userId": 1
      }]
    }]
  */
})
```

当我们为一个关联添加了 `as` 设置别名之后，则必须指定 `as` 之后的名称：

```javascript
User.findAll({ include: [{ model: Tool, as: 'Instruments' }] }).then(users => {
  console.log(JSON.stringify(users))

  /*
    [{
      "name": "John Doe",
      "id": 1,
      "createdAt": "2013-03-20T20:31:45.000Z",
      "updatedAt": "2013-03-20T20:31:45.000Z",
      "Instruments": [{
        "name": "Toothpick",
        "id": 1,
        "createdAt": null,
        "updatedAt": null,
        "userId": 1
      }]
    }]
  */
})
```

在你设置了别名之后，你除了使用关联前的对象名，还可以直接使用别名进行 `include` 操作：

```javascript
User.findAll({ include: ['Instruments'] }).then(users => {
  console.log(JSON.stringify(users))

  /*
    [{
      "name": "John Doe",
      "id": 1,
      "createdAt": "2013-03-20T20:31:45.000Z",
      "updatedAt": "2013-03-20T20:31:45.000Z",
      "Instruments": [{
        "name": "Toothpick",
        "id": 1,
        "createdAt": null,
        "updatedAt": null,
        "userId": 1
      }]
    }]
  */
})

User.findAll({ include: [{ association: 'Instruments' }] }).then(users => {
  console.log(JSON.stringify(users))

  /*
    [{
      "name": "John Doe",
      "id": 1,
      "createdAt": "2013-03-20T20:31:45.000Z",
      "updatedAt": "2013-03-20T20:31:45.000Z",
      "Instruments": [{
        "name": "Toothpick",
        "id": 1,
        "createdAt": null,
        "updatedAt": null,
        "userId": 1
      }]
    }]
  */
})
```

在 `include` 中，你同样可以使用 `where` 查询语句：

```javascript
User.findAll({
    include: [{
        model: Tool,
        as: 'Instruments',
        where: { name: { $like: '%ooth%' } }
    }]
}).then(users => {
    console.log(JSON.stringify(users))

    /*
      [{
        "name": "John Doe",
        "id": 1,
        "createdAt": "2013-03-20T20:31:45.000Z",
        "updatedAt": "2013-03-20T20:31:45.000Z",
        "Instruments": [{
          "name": "Toothpick",
          "id": 1,
          "createdAt": null,
          "updatedAt": null,
          "userId": 1
        }]
      }],

      [{
        "name": "John Smith",
        "id": 2,
        "createdAt": "2013-03-20T20:31:45.000Z",
        "updatedAt": "2013-03-20T20:31:45.000Z",
        "Instruments": [{
          "name": "Toothpick",
          "id": 1,
          "createdAt": null,
          "updatedAt": null,
          "userId": 1
        }]
      }],
    */
  })
```

### 在上一层模型中指定 `eager` 加载模型的 `where` 查询

要将 `include` 中的 `where` 查询从 `include` 中移除，可以在上层的 `WHERE` 语句中使用 `$nested.column$` 语法查询。

```javascript
User.findAll({
    where: {
        '$Instruments.name$': { $iLike: '%ooth%' }
    },
    include: [{
        model: Tool,
        as: 'Instruments'
    }]
}).then(users => {
    console.log(JSON.stringify(users));

    /*
      [{
        "name": "John Doe",
        "id": 1,
        "createdAt": "2013-03-20T20:31:45.000Z",
        "updatedAt": "2013-03-20T20:31:45.000Z",
        "Instruments": [{
          "name": "Toothpick",
          "id": 1,
          "createdAt": null,
          "updatedAt": null,
          "userId": 1
        }]
      }],

      [{
        "name": "John Smith",
        "id": 2,
        "createdAt": "2013-03-20T20:31:45.000Z",
        "updatedAt": "2013-03-20T20:31:45.000Z",
        "Instruments": [{
          "name": "Toothpick",
          "id": 1,
          "createdAt": null,
          "updatedAt": null,
          "userId": 1
        }]
      }],
    */
```

### 包含所有关联数据

```javascript
User.findAll({ include: [{ all: true }]});
```

### 包含被软删除了的记录

```javascript
User.findAll({
    include: [{
        model: Tool,
        where: { name: { $like: '%ooth%' } },
        paranoid: false // query and loads the soft deleted records
    }]
});
```

### Ordering Eager Loaded Associations

`one-to-many` 关联关系：

```javascript
Company.findAll({ include: [ Division ], order: [ [ Division, 'name' ] ] });
Company.findAll({ include: [ Division ], order: [ [ Division, 'name', 'DESC' ] ] });
Company.findAll({
  include: [ { model: Division, as: 'Div' } ],
  order: [ [ { model: Division, as: 'Div' }, 'name' ] ]
});
Company.findAll({
  include: [ { model: Division, as: 'Div' } ],
  order: [ [ { model: Division, as: 'Div' }, 'name', 'DESC' ] ]
});
Company.findAll({
  include: [ { model: Division, include: [ Department ] } ],
  order: [ [ Division, Department, 'name' ] ]
});
```

`many-to-many` 关联关系：

```javascript
Company.findAll({
  include: [ { model: Division, include: [ Department ] } ],
  order: [ [ Division, DepartmentDivision, 'name' ] ]
});
```

### 嵌套 Eager loading

```javascript
User.findAll({
  include: [
    {model: Tool, as: 'Instruments', include: [
      {model: Teacher, include: [ /* etc */]}
    ]}
  ]
}).then(users => {
  console.log(JSON.stringify(users))

  /*
    [{
      "name": "John Doe",
      "id": 1,
      "createdAt": "2013-03-20T20:31:45.000Z",
      "updatedAt": "2013-03-20T20:31:45.000Z",
      "Instruments": [{ // 1:M and N:M association
        "name": "Toothpick",
        "id": 1,
        "createdAt": null,
        "updatedAt": null,
        "userId": 1,
        "Teacher": { // 1:1 association
          "name": "Jimi Hendrix"
        }
      }]
    }]
  */
})
```

这将会产生一个 `outer join`，一个内嵌模型的 `where` 查询会产生一个 `inner join`：

```javascript
User.findAll({
  include: [{
    model: Tool,
    as: 'Instruments',
    include: [{
      model: Teacher,
      where: {
        school: "Woodstock Music School"
      },
      required: false
    }]
  }]
}).then(users => {
  /* ... */
})
```

要嵌套加载所有的模型数据：

```javascript
User.findAll({ include: [{ all: true, nested: true }]});
```