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

