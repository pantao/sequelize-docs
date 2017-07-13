# 作用域

作用域允许你定义一些常见的查询，以方便之后快速的访问它们，作用域可以包含所有普通查询方法的属性，比如 `where`、`include` 以及 `limit` 等。

## 定义：

作用域可以在模型定义时被定义，它们可以是一个查询对象，或者一个可以返回一个查询对象的函数。而对于默认的作用域，只能是一个查询对象。

```javascript
const Project = sequelize.define('project', {
  // Attributes
}, {
  defaultScope: {
    where: {
      active: true
    }
  },
  scopes: {
    deleted: {
      where: {
        deleted: true
      }
    },
    activeUsers: {
      include: [
        { model: User, where: { active: true }}
      ]
    },
    random: function () {
      return {
        where: {
          someNumber: Math.random()
        }
      }
    },
    accessLevel: function (value) {
      return {
        where: {
          accessLevel: {
            $gte: value
          }
        }
      }
    }
  }
});
```

你同样还可以在模型被创建之后，使用 `addScope` 方法添加作用域：

默认作用域总是可访问的，这表示，你使用 `Project.findAll()` ，将会创建下面这样的SQL：

```sql
SELECT * FROM projects WHERE active = true
```

默认作用域可以通过 `unscope()` 或者 `scope(null)` 重置：

```javascript
Project.scope('deleted').findAll(); // Removes the default scope
```

```sql
SELECT * FROM projects WHERE deleted = true
```

同样的，你还可以在一个创建了作用域的模型中， `include` 另一个作用域，这使得你不再需要创建重复的 `include`、`attributes` 或者 `where`：

```javascript
activeUsers: {
  include: [
    { model: User.scope('active')}
  ]
}
```

## 使用

作用域可以通过模型的 `.scope` 方法调用，该方法接受一个或者多个作用域名称作为参数，`.scope` 返回的对象具有所有的普通方法：`findAll`、`update`、`count`、`destroy` 等：

```javascript
const DeletedProjects = Project.scope('deleted');

DeletedProjects.findAll();
// some time passes

// let's look for deleted projects again!
DeletedProjects.findAll();
```

对于函数式作用域定义，如果该函数不接受任何参数，那么就像其它的作用域定义一样直接访问即可，但是如果该作用域定义接受一个参数，那么你可以像下面这样传递参数给它：

```javascript
Project.scope('random', { method: ['accessLevel', 19]}).findAll();
```

```sql
SELECT * FROM projects WHERE someNumber = 42 AND accessLevel >= 19
```

## 合并

多个作用域可以被合并为一个作用域去作用，只需要将多个作用域的名称放在一个数组中，传递给 `.scope` 方法即可：

```javascript
// These two are equivalent
Project.scope('deleted', 'activeUsers').findAll();
Project.scope(['deleted', 'activeUsers']).findAll();
```

```sql
SELECT * FROM projects
INNER JOIN users ON projects.userId = users.id
AND users.active = true
```

如果你想合并使用默认作用域与某一个特定的其它作用域，使用 `defaultScope` 作为 `key` 即可访问默认作用域：

```javascript
Project.scope('defaultScope', 'deleted').findAll();
```

```sql
SELECT * FROM projects WHERE active = true AND deleted = true
```

如果被合并的作用域中存在两个同样的定义，那么后面出现的作用域的设置将覆盖前面的设置，就像 `_.assign` 一样：

```javascript
{
  scope1: {
    where: {
      firstName: 'bob',
      age: {
        $gt: 20
      }
    },
    limit: 2
  },
  scope2: {
    where: {
      age: {
        $gt: 30
      }
    },
    limit: 10
  }
}
```

调用  `.scope('scope1', 'scope2')` 将得到下面这样的SQL：

```sql
WHERE firstName = 'bob' AND age > 30 LIMIT 10
```

对于我们直接传递给查询函数的逻辑，同样会覆盖作用域中的相同的设置，或者与不同的设置进行合并：

```javascript
Project.scope('deleted').findAll({
  where: {
    firstName: 'john'
  }
})
```

```sql
WHERE deleted = true AND firstName = 'john'
```

## 关联

Sequelize有两个不同但相关的概念，差异是很微妙的，但是却非常重要：

- **关联作用域** —— 这允许你设置默认的用于 `getting` 或者 `setting` 关联关系的属性，这在实现多态关联是很有用，只有在使用 `get`、`set`以及 `create` 的关联模型时，才会在两个模型之间的关联上调用。
- **已关联模型的作用域** —— 这允许你设置默认的或者其它的作用域，用于查询关联数据，并且，允许你传递一个定义了作用域的模型作为关联关系的一方，这些作用域都同时适用于模型上的查询以及关联查询。

考虑一下这样的场景，现在有两个模型 `Post` 与 `Comment`，`Comment` 被关联至多个其它模型（比如`Image`、`Video`等），这时，`Comment` 的关联就是多态的，`Comment` 有一个名为 `commentable` 的属性，同时还有一个 `commentable_id` 表示关联的模型的ID。

```javascript
this.Post.hasMany(this.Comment, {
  foreignKey: 'commentable_id',
  scope: {
    commentable: 'post'
  }
});
```

当我们调用 `post.getComments()` 时，会自动的加上 `WHERE commentable = 'post'` 查询，同时，当我们添加一些新的 `Comment` 至 `Post` 实例时，该 `Comment` 的 `commentable` 会自动的设置为 `post`。

再考虑到 `Post` 有一个默认的作用域 `where: { active: true }`，该作用域会一直存在于被关联的模型（Post），而没有像 `commentable` 作用域一样关联至模型，就像 `Post.findAll()` 会基于默认作用域一样， `User.getPosts()` 同样会只展示 `active` Post。

要禁用默认作用域，可以使用 `scope: null` 来表示：`User.getPosts({scope:null})`，如果你想合并多个作用域的话，那也可以使用：

```javascript
User.getPosts({
  scope: ['scope1', 'scope2']
})
```

如果你想创建一些快捷方式，用于快速访问关联的作用域模型，你可以像下面这样：

```javascript
const Post = sequelize.define('post', attributes, {
  defaultScope: {
    where: {
      active: true
    }
  },
  scopes: {
    deleted: {
      where: {
        deleted: true
      }
    }
  }
});

User.hasMany(Post); // regular getPosts association
User.hasMany(Post.scope('deleted'), { as: 'deletedPosts' });
```

```javascript
User.getPosts(); // WHERE active = true
User.getDeletedPosts(); // WHERE deleted = true
```