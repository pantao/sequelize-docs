# 关联

本章节将主要讨论如果在 Sequelize 中创建各种关联关系，当我们调用 `User.hasOne(Project)` 时，就表示 `User` 模型为**源**，而 `Project` 为 **目标**。

## 一对一关联 

一对一关联表示的是两个不同的模型之间通过一个外键关联。

### BelongsTo

BelongsTo 关联表示的是外键关联至 **源** 模型上的关联关系，在下面的简单示例中，有一个 `Player` 将属于某一个 `Team`：

```javascript
const Player = this.sequelize.define('player', {/* attributes */});
const Team  = this.sequelize.define('team', {/* attributes */});

Player.belongsTo(Team); // 这将会在 `Player` 模型上添加一个名为 `teamId` 的字段，以表示它属于哪个 `Team`
```

#### 外键

默认情况下， `belongsTo` 会自动创建一个格式为目标模型名称+目标模型主键名称的新名称，作为外键名称，默认的，使用的命名方式为 `camelCase` ，当然，如果你设置模型的 `underscored: true`，那么名称将为 `snake_case` 方式。

```javascript
const User = this.sequelize.define('user', {/* attributes */})
const Company  = this.sequelize.define('company', {/* attributes */});

User.belongsTo(Company); // 将会添加 companyId 至 User

const User = this.sequelize.define('user', {/* attributes */}, {underscored: true})
const Company  = this.sequelize.define('company', {
  uuid: {
    type: Sequelize.UUID,
    primaryKey: true
  }
});

User.belongsTo(Company); // 将会添加 company_uuid 至 User
```

当定义了 `as` 属性时，其值将作为目标模型的别名。

```javascript
const User = this.sequelize.define('user', {/* attributes */})
const UserRole  = this.sequelize.define('userRole', {/* attributes */});

User.belongsTo(UserRole, {as: 'role'}); // 添加 roleId 至 User （而并不是 userRoleId）
```

当然，我们并不总是所有时候都使用自动添加的键名，通过 `foreignKey` 选项即可自定义外键名称。

```javascript
const User = this.sequelize.define('user', {/* attributes */})
const Company  = this.sequelize.define('company', {/* attributes */});

User.belongsTo(Company, {foreignKey: 'fk_company'}); // 添加 fk_company 至用户
```

#### 目标键（Target Key）

目标键就是目标模型中被用于关联的那个键，默认的， `belongsTo` 会使用目标模型的主键，但是你同样也可以自定义使用其它键：

```javascript
const User = this.sequelize.define('user', {/* attributes */})
const Company  = this.sequelize.define('company', {/* attributes */});

User.belongsTo(Company, {foreignKey: 'fk_companyname', targetKey: 'name'}); // 添加 fk_companyname 至 User
```

### HasOne

```javascript
const User = sequelize.define('user', {/* ... */})
const Project = sequelize.define('project', {/* ... */})

// 单向关联
Project.hasOne(User)

/**
 * 在本例中， `hasOne` 将添加一个名为 `projectId` 的属性至 `User` 模型，
 * 另外，`Project.prototype` 将自动获得两个方法：`getUser` 以及 `setUser`。
 * 如果你启用了 `underscore`，那么字段名称将为 `project_id`。
 *
 * 外键将保存在 `users` 数据表，当然，你同样还可以定义外键名称，比如：
 */
Project.hasOne(User, { foreignKey: 'initiator_id' })

/**
 * Sequelize 会使用模型的名称作为被关联的模型的访问，但你同样可以使用别名重新定义
 * 它：
 */

Project.hasOne(User, { as: 'Initiator' })
// 现在，你将得到两个访问访问名为：`Project.getInitiator` 与 `Project.setInitiator`

// 或者，让我们定义一些自关联
const Person = sequelize.define('person', { /* ... */})

Person.hasOne(Person, {as: 'Father'})
// 此时会添加 `fatherId` 与 `Person` 模型。

// 同样的，可以这产：
Person.hasOne(Person, {as: 'Father', foreignKey: 'DadId'})
// 现在会添加 `dadId` 至 `Person`

// 在上面两个方式，你都可以访问
Person#setFather
Person#getFather

// 同时，你还可以将一个模型多次关联至另一个模型
Team.hasOne(Game, {as: 'HomeTeam', foreignKey : 'homeTeamId'});
Team.hasOne(Game, {as: 'AwayTeam', foreignKey : 'awayTeamId'});

Game.belongsTo(Team);
```

虽然很多时候，我们将 `1:1` 关联称之为 `HasOne` 关联，但是通常都会使用 `belongsTo` ，因为 `belongsTo` 会将外键保存在源模型中，而 `hasOne` 则将外键保存在目标模型中。

### `HasOne` 与 `BelongsTo` 之间的区别

在 Sequelize 中，`1:1` 关联可以使用 `belongsTo` 与 `hasOne` ，但是它们之间适应的场景还是有区别的，下面我们来了解一下下什么时候该使用什么方式 ：

现在假设我们有两个数据表 `Player` 与 `Team`：

```javascript
const Player = this.sequelize.define('player', {/* attributes */})
const Team  = this.sequelize.define('team', {/* attributes */});
```

当我们关联这两个数据模型时，可以将它们称之为 **源** 与 **目标**，比如：

将 **Player** 当作 **源**，同时将 **Team** 当作 **目标**：

```javascript
Player.belongsTo(Team);
// 或
Player.hasOne(Team);
```

或者将 **Team** 当作 **源**，而把 **Player** 当作 **目标**：

```javascript
Team.belongsTo(Player);
// 或
Team.hasOne(Player);
```

HasOne and BelongsTo insert the association key in different models from each other. HasOne inserts the association key in target model whereas BelongsTo inserts the association key in the source model.

Here is an example demonstrating use cases of BelongsTo and HasOne.

```javascript
const Player = this.sequelize.define('player', {/* attributes */})
const Coach  = this.sequelize.define('coach', {/* attributes */})
const Team  = this.sequelize.define('team', {/* attributes */});
```

Suppose our Player model has information about its team as teamId column. Information about each Team's Coach is stored in the Team model as coachId column. These both scenarios requires different kind of 1:1 relation because foreign key relation is present on different models each time.

When information about association is present in source model we can use belongsTo. In this case Player is suitable for belongsTo because it has teamId column.

```javascript
Player.belongsTo(Team)  // `teamId` will be added on Player / Source model
```

When information about association is present in target model we can use hasOne. In this case Coach is suitable for hasOne because Team model store information about its Coach as coachId field.

```javascript
Coach.hasOne(Team)  // `coachId` will be added on Team / Target model
```

## 一对多关联（One-To-Many）

一对多关联将链接一个源以及多个目标，而每一个目标，则关联且仅关联至一个源：

```javascript
const User = sequelize.define('user', {/* ... */})
const Project = sequelize.define('project', {/* ... */})

// 现在让我们定义一个 `hasMany` 关联
Project.hasMany(User, {as: 'Workers'})
```

在上面的代码片段中，我们将添加 `project_id` 或者 `projectId` 至用户，所有的 `Project` 实例都将有 `getWorkers` 以及 `setWorkers` 方法。

有些时候我们希望通过自定义的键创建关联：

```javascript
const City = sequelize.define('city', { countryCode: Sequelize.STRING });
const Country = sequelize.define('country', { isoCode: Sequelize.STRING });

// 下面我们可以通过 `countryCode` 独步 `Country` 与 `City`
Country.hasMany(City, {foreignKey: 'countryCode', sourceKey: 'isoCode'});
City.belongsTo(Country, {foreignKey: 'countryCode', targetKey: 'isoCode'});
```

### 属于多个的关联 （Belongs-To-Many）

`Belongs-To-Many` 关联多个源与多个目标。

```javascript
Project.belongsToMany(User, {through: 'UserProject'});
User.belongsToMany(Project, {through: 'UserProject'});
```

这会自动创建一个名为 `UserProject` 的模型，该模型将存在两个字段：`projectId` 与 `userId`，属性是否是 `camelCase` 取决于被关联的这两个模型的设置。

`through` 参数则是 **必须** 的。

上面的定义，会自动添加 `getUsers`、`setUsers`、`addUser`、`addUsers` 至 `Project` 模型，同时还会添加 `getProjects`、`setProjects`、`addProject` 以及 `addProjects` 与 `Users` 模型。

有些时候，你也会在使用这些关联的过程中使用非模型名称，那么，你同样可以使用别名功能：

```javascript
User.belongsToMany(Project, { as: 'Tasks', through: 'worker_tasks', foreignKey: 'userId' })
Project.belongsToMany(User, { as: 'Workers', through: 'worker_tasks', foreignKey: 'projectId' })
```

`foreignKey` 将允许你设置 **源模型** 在 `throught` 关联中的键，`otherKey` 允许你设置 **目标模型** 的键。

```javascript
User.belongsToMany(Project, { as: 'Tasks', through: 'worker_tasks', foreignKey: 'userId', otherKey: 'projectId'})
```

当然，你还可以定义自关联：

```javascript
Person.belongsToMany(Person, { as: 'Children', through: 'PersonChildren' })
// This will create the table PersonChildren which stores the ids of the objects.
```

如果你还想在关联表中定义更多的字段，那么你可以直接先创建关联模型：

```javascript
const User = sequelize.define('user', {})
const Project = sequelize.define('project', {})
const UserProjects = sequelize.define('userProjects', {
    status: DataTypes.STRING
})

User.belongsToMany(Project, { through: UserProjects })
Project.belongsToMany(User, { through: UserProjects })
```

这个时候，如果说我们要给用户添加一个项目，同时设置该关联关系的状态为 `started`，可以这样：

```javascript
user.addProject(project, { through: { status: 'started' }})
```

By default the code above will add projectId and userId to the UserProjects table, and remove any previously defined primary key attribute - the table will be uniquely identified by the combination of the keys of the two tables, and there is no reason to have other PK columns. To enforce a primary key on the UserProjects model you can add it manually.

```javascript
const UserProjects = sequelize.define('userProjects', {
  id: {
    type: Sequelize.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  status: DataTypes.STRING
})
```

With Belongs-To-Many you can query based on through relation and select specific attributes. For example using findAll with through

```javascript
User.findAll({
  include: [{
    model: Project,
    through: {
      attributes: ['createdAt', 'startedAt', 'finishedAt'],
      where: {completed: true}
    }
  }]
});
```

## Scopes

This section concerns association scopes. For a definition of association scopes vs. scopes on associated models, see [Scopes](scopes.md).

Association scopes allow you to place a scope (a set of default attributes for get and create) on the association. Scopes can be placed both on the associated model (the target of the association), and on the through table for n:m relations.

### 1:m

Assume we have tables Comment, Post, and Image. A comment can be associated to either an image or a post via commentable_id and commentable - we say that Post and Image are Commentable

```javascript
const Comment = this.sequelize.define('comment', {
  title: Sequelize.STRING,
  commentable: Sequelize.STRING,
  commentable_id: Sequelize.INTEGER
});

Comment.prototype.getItem = function() {
  return this['get' + this.get('commentable').substr(0, 1).toUpperCase() + this.get('commentable').substr(1)]();
};

Post.hasMany(this.Comment, {
  foreignKey: 'commentable_id',
  constraints: false,
  scope: {
    commentable: 'post'
  }
});
Comment.belongsTo(this.Post, {
  foreignKey: 'commentable_id',
  constraints: false,
  as: 'post'
});

Image.hasMany(this.Comment, {
  foreignKey: 'commentable_id',
  constraints: false,
  scope: {
    commentable: 'image'
  }
});
Comment.belongsTo(this.Image, {
  foreignKey: 'commentable_id',
  constraints: false,
  as: 'image'
});
```

`constraints: false`, disables references constraints - since the `commentable_id` column references several tables, we cannot add a `REFERENCES` constraint to it. Note that the Image -> Comment and Post -> Comment relations define a scope, `commentable`: '`image`' and `commentable`: '`post`' respectively. This scope is automatically applied when using the association functions:

```javascript
image.getComments()
```

```sql
SELECT * FROM comments WHERE commentable_id = 42 AND commentable = 'image';
```

```javascript
image.createComment({
  title: 'Awesome!'
})
```

```sql
INSERT INTO comments (title, commentable_id, commentable) VALUES ('Awesome!', 42, 'image');
```

```javascript
image.addComment(comment);
```

```sql
UPDATE comments SET commentable_id = 42, commentable = 'image'
```

The `getItem` utility function on `Comment` completes the picture - it simply converts the `commentable` string into a call to either `getImage` or `getPost`, providing an abstraction over whether a comment belongs to a post or an image.

### n:m

Continuing with the idea of a polymorphic model, consider a tag table - an item can have multiple tags, and a tag can be related to several items.

For brevity, the example only shows a Post model, but in reality Tag would be related to several other models.

```javascript
const ItemTag = sequelize.define('item_tag', {
  id : {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  tag_id: {
    type: DataTypes.INTEGER,
    unique: 'item_tag_taggable'
  },
  taggable: {
    type: DataTypes.STRING,
    unique: 'item_tag_taggable'
  },
  taggable_id: {
    type: DataTypes.INTEGER,
    unique: 'item_tag_taggable',
    references: null
  }
});
const Tag = sequelize.define('tag', {
  name: DataTypes.STRING
});

Post.belongsToMany(Tag, {
  through: {
    model: ItemTag,
    unique: false,
    scope: {
      taggable: 'post'
    }
  },
  foreignKey: 'taggable_id',
  constraints: false
});
Tag.belongsToMany(Post, {
  through: {
    model: ItemTag,
    unique: false
  },
  foreignKey: 'tag_id',
  constraints: false
});
```

Notice that the scoped column (`taggable`) is now on the through model (`ItemTag`).

We could also define a more restrictive association, for example, to get all pending tags for a post by applying a scope of both the through model (`ItemTag`) and the target model (`Tag`):

```javascript
Post.hasMany(Tag, {
  through: {
    model: ItemTag,
    unique: false,
    scope: {
      taggable: 'post'
    }
  },
  scope: {
    status: 'pending'
  },
  as: 'pendingTags',
  foreignKey: 'taggable_id',
  constraints: false
});

Post.getPendingTags();
```

```sql
SELECT `tag`.*  INNER JOIN `item_tags` AS `item_tag`
ON `tag`.`id` = `item_tag`.`tagId`
  AND `item_tag`.`taggable_id` = 42
  AND `item_tag`.`taggable` = 'post'
WHERE (`tag`.`status` = 'pending');
```

`constraints: false` disables references constraints on the `taggable_id` column. Because the column is polymorphic, we cannot say that it `REFERENCES` a specific table.

## Naming strategy

By default sequelize will use the model name (the name passed to sequelize.define) to figure out the name of the model when used in associations. For example, a model named user will add the functions get/set/add User to instances of the associated model, and a property named .user in eager loading, while a model named User will add the same functions, but a property named .User (notice the upper case U) in eager loading.

As we've already seen, you can alias models in associations using as. In single associations (has one and belongs to), the alias should be singular, while for many associations (has many) it should be plural. Sequelize then uses the [inflection](https://www.npmjs.org/package/inflection) library to convert the alias to its singular form. However, this might not always work for irregular or non-english words. In this case, you can provide both the plural and the singular form of the alias:

```javascript
User.belongsToMany(Project, { as: { singular: 'task', plural: 'tasks' }})
// Notice that inflection has no problem singularizing tasks, this is just for illustrative purposes.
```

If you know that a model will always use the same alias in associations, you can provide it when creating the model

```
const Project = sequelize.define('project', attributes, {
  name: {
    singular: 'task',
    plural: 'tasks',
  }
})

User.belongsToMany(Project);
```

This will add the functions `add`/`set`/`get` Tasks to user instances.

Remember, that using `as` to change the name of the association will also change the name of the foreign key. When using `as`, it is safest to also specify the foreign key.

```javascript
Invoice.belongsTo(Subscription)
Subscription.hasMany(Invoice)
```

Without `as`, this adds `subscriptionId` as expected. However, if you were to say `Invoice.belongsTo(Subscription, { as: 'TheSubscription' })`, you will have both `subscriptionId` and `theSubscriptionId`, because sequelize is not smart enough to figure that the calls are two sides of the same relation. 'foreignKey' fixes this problem;

```javascript
Invoice.belongsTo(Subscription, , { as: 'TheSubscription', foreignKey: 'subscription_id' })
Subscription.hasMany(Invoice, { foreignKey: 'subscription_id' )
```

## Associating objects

Because Sequelize is doing a lot of magic, you have to call `Sequelize.sync` after setting the associations! Doing so will allow you the following:

```javascript
Project.belongsToMany(Task)
Task.belongsToMany(Project)

Project.create()...
Task.create()...
Task.create()...

// save them... and then:
project.setTasks([task1, task2]).then(() => {
  // saved!
})

// ok, now they are saved... how do I get them later on?
project.getTasks().then(associatedTasks => {
  // associatedTasks is an array of tasks
})

// You can also pass filters to the getter method.
// They are equal to the options you can pass to a usual finder method.
project.getTasks({ where: 'id > 10' }).then(tasks => {
  // tasks with an id greater than 10 :)
})

// You can also only retrieve certain fields of a associated object.
project.getTasks({attributes: ['title']}).then(tasks => {
  // retrieve tasks with the attributes "title" and "id"
})
```

To remove created associations you can just call the set method without a specific id:

```
// remove the association with task1
project.setTasks([task2]).then(associatedTasks => {
  // you will get task2 only
})

// remove 'em all
project.setTasks([]).then(associatedTasks => {
  // you will get an empty array
})

// or remove 'em more directly
project.removeTask(task1).then(() => {
  // it's gone
})

// and add 'em again
project.addTask(task1).then(function() {
  // it's back again
})
```

You can of course also do it vice versa:

```javascript
// project is associated with task1 and task2
task2.setProject(null).then(function() {
  // and it's gone
})
```

For `hasOne`/`belongsTo` its basically the same:

```javascript
Task.hasOne(User, {as: "Author"})
Task#setAuthor(anAuthor)
```

Adding associations to a relation with a custom join table can be done in two ways (continuing with the associations defined in the previous chapter):

```javascript
// Either by adding a property with the name of the join table model to the object, before creating the association
project.UserProjects = {
  status: 'active'
}
u.addProject(project)

// Or by providing a second options.through argument when adding the association, containing the data that should go in the join table
u.addProject(project, { through: { status: 'active' }})


// When associating multiple objects, you can combine the two options above. In this case the second argument
// will be treated as a defaults object, that will be used if no data is provided
project1.UserProjects = {
    status: 'inactive'
}

u.setProjects([project1, project2], { through: { status: 'active' }})
// The code above will record inactive for project one, and active for project two in the join table
```

When getting data on an association that has a custom join table, the data from the join table will be returned as a DAO instance:

```javascript
u.getProjects().then(projects => {
  const project = projects[0]

  if (project.UserProjects.status === 'active') {
    // .. do magic

    // since this is a real DAO instance, you can save it directly after you are done doing magic
    return project.UserProjects.save()
  }
})
```

If you only need some of the attributes from the join table, you can provide an array with the attributes you want:

```javascript
// This will select only name from the Projects table, and only status from the UserProjects table
user.getProjects({ attributes: ['name'], joinTableAttributes: ['status']})
```

## Check associations

You can also check if an object is already associated with another one (N:M only). Here is how you'd do it:

```javascript
// check if an object is one of associated ones:
Project.create({ /* */ }).then(project => {
  return User.create({ /* */ }).then(user => {
    return project.hasUser(user).then(result => {
      // result would be false
      return project.addUser(user).then(() => {
        return project.hasUser(user).then(result => {
          // result would be true
        })
      })
    })
  })
})

// check if all associated objects are as expected:
// let's assume we have already a project and two users
project.setUsers([user1, user2]).then(() => {
  return project.hasUsers([user1]);
}).then(result => {
  // result would be false
  return project.hasUsers([user1, user2]);
}).then(result => {
  // result would be true
})
```

## Foreign Keys

When you create associations between your models in sequelize, foreign key references with constraints will automatically be created. The setup below:

```javascript
const Task = this.sequelize.define('task', { title: Sequelize.STRING })
const User = this.sequelize.define('user', { username: Sequelize.STRING })

User.hasMany(Task)
Task.belongsTo(User)
```

Will generate the following SQL:

```sql
CREATE TABLE IF NOT EXISTS `User` (
  `id` INTEGER PRIMARY KEY,
  `username` VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS `Task` (
  `id` INTEGER PRIMARY KEY,
  `title` VARCHAR(255),
  `user_id` INTEGER REFERENCES `User` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
);
```

The relation between task and user injects the `user_id` foreign key on tasks, and marks it as a reference to the `User` table. By default `user_id` will be set to `NULL` if the referenced user is deleted, and updated if the id of the user id updated. These options can be overridden by passing `onUpdate` and `onDelete` options to the association calls. The validation options are `RESTRICT`, `CASCADE`, `NO ACTION`, `SET DEFAULT`, `SET NULL`.

For 1:1 and 1:m associations the default option is `SET NULL` for deletion, and `CASCADE` for updates. For n:m, the default for both is `CASCADE`. This means, that if you delete or update a row from one side of an n:m association, all the rows in the join table referencing that row will also be deleted or updated.

Adding constraints between tables means that tables must be created in the database in a certain order, when using `sequelize.sync`. If Task has a reference to User, the User table must be created before the Task table can be created. This can sometimes lead to circular references, where sequelize cannot find an order in which to sync. Imagine a scenario of documents and versions. A document can have multiple versions, and for convenience, a document has an reference to it's current version.

```javascript
const Document = this.sequelize.define('document', {
  author: Sequelize.STRING
})
const Version = this.sequelize.define('version', {
  timestamp: Sequelize.DATE
})

Document.hasMany(Version) // This adds document_id to version
Document.belongsTo(Version, { as: 'Current', foreignKey: 'current_version_id'}) // This adds current_version_id to document
```

However, the code above will result in the following error: `Cyclic dependency found. 'Document' is dependent of itself. Dependency Chain: Document -> Version => Document`. In order to alleviate that, we can pass `constraints: false` to one of the associations:

```javascript
Document.hasMany(Version)
Document.belongsTo(Version, { as: 'Current', foreignKey: 'current_version_id', constraints: false})
```

Which will allow us to sync the tables correctly:

```sql
CREATE TABLE IF NOT EXISTS `Document` (
  `id` INTEGER PRIMARY KEY,
  `author` VARCHAR(255),
  `current_version_id` INTEGER
);
CREATE TABLE IF NOT EXISTS `Version` (
  `id` INTEGER PRIMARY KEY,
  `timestamp` DATETIME,
  `document_id` INTEGER REFERENCES `Document` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
);
```

### Enforcing a foreign key reference without constraints

Sometimes you may want to reference another table, without adding any constraints, or associations. In that case you can manually add the reference attributes to your schema definition, and mark the relations between them.

```javascript
// Series has a trainer_id=Trainer.id foreign reference key after we call Trainer.hasMany(series)
const Series = sequelize.define('series', {
  title:        DataTypes.STRING,
  sub_title:    DataTypes.STRING,
  description:  DataTypes.TEXT,

  // Set FK relationship (hasMany) with `Trainer`
  trainer_id: {
    type: DataTypes.INTEGER,
    references: {
      model: "trainers",
      key: "id"
    }
  }
})

const Trainer = sequelize.define('trainer', {
  first_name: DataTypes.STRING,
  last_name:  DataTypes.STRING
});

// Video has a series_id=Series.id foreign reference key after we call Series.hasOne(Video)...
const Video = sequelize.define('video', {
  title:        DataTypes.STRING,
  sequence:     DataTypes.INTEGER,
  description:  DataTypes.TEXT,

  // set relationship (hasOne) with `Series`
  series_id: {
    type: DataTypes.INTEGER,
    references: {
      model: Series, // Can be both a string representing the table name, or a reference to the model
      key:   "id"
    }
  }
});

Series.hasOne(Video);
Trainer.hasMany(Series);
```

## Creating with associations

An instance can be created with nested association in one step, provided all elements are new.

### Creating elements of a "BelongsTo", "Has Many" or "HasOne" association

Consider the following models:

```javascript
const Product = this.sequelize.define('product', {
  title: Sequelize.STRING
});
const User = this.sequelize.define('user', {
  first_name: Sequelize.STRING,
  last_name: Sequelize.STRING
});
const Address = this.sequelize.define('address', {
  type: Sequelize.STRING,
  line_1: Sequelize.STRING,
  line_2: Sequelize.STRING,
  city: Sequelize.STRING,
  state: Sequelize.STRING,
  zip: Sequelize.STRING,
});

const Product.User = Product.belongsTo(User);
const User.Addresses = User.hasMany(Address);
// Also works for `hasOne`
```

A new `Product`, `User`, and one or more `Address` can be created in one step in the following way:

```javascript
return Product.create({
  title: 'Chair',
  user: {
    first_name: 'Mick',
    last_name: 'Broadstone',
    addresses: [{
      type: 'home',
      line_1: '100 Main St.',
      city: 'Austin',
      state: 'TX',
      zip: '78704'
    }]
  }
}, {
  include: [{
    association: Product.User,
    include: [ User.Addresses ]
  }]
});
```

Here, our user model is called `user`, with a lowercase u - This means that the property in the object should also be `user`. If the name given to `sequelize.define` was `User`, the key in the object should also be `User`. Likewise for `addresses`, except it's pluralized being a `hasMany` association.

### Creating elements of a "BelongsTo" association with an alias

The previous example can be extended to support an association alias.

```javascript
const Creator = Product.belongsTo(User, {as: 'creator'});

return Product.create({
  title: 'Chair',
  creator: {
    first_name: 'Matt',
    last_name: 'Hansen'
  }
}, {
  include: [ Creator ]
});
```

### Creating elements of a "HasMany" or "BelongsToMany" association

Let's introduce the ability to associate a product with many tags. Setting up the models could look like:

```javascript
const Tag = this.sequelize.define('tag', {
  name: Sequelize.STRING
});

Product.hasMany(Tag);
// Also works for `belongsToMany`.
```

Now we can create a product with multiple tags in the following way:

```javascript
Product.create({
  id: 1,
  title: 'Chair',
  tags: [
    { name: 'Alpha'},
    { name: 'Beta'}
  ]
}, {
  include: [ Tag ]
})
```

And, we can modify this example to support an alias as well:

```javascript
const Categories = Product.hasMany(Tag, {as: 'categories'});

Product.create({
  id: 1,
  title: 'Chair',
  categories: [
    {id: 1, name: 'Alpha'},
    {id: 2, name: 'Beta'}
  ]
}, {
  include: [{
    model: Categories,
    as: 'categories'
  }]
})
```
