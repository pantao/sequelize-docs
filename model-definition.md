# 模型定义

要定义模型与数据表之间的关联关系，使用 `define` 方法，Sequelize 会自动的添加 `createdAt` 与 `updatedAt` 两个字段，用于表示记录是在什么时候被创建的，以及最后更新于什么时候。如果你不想在模型中使用 `timestamps` 功能，或者需要更多的 `timestamps` 类型，或者需要直接将模型关联到已有的数据表，请直接查看**配置**章节。

```javascript
const Project = sequelize.define('project', {
  title: Sequelize.STRING,
  description: Sequelize.TEXT
})

const Task = sequelize.define('task', {
  title: Sequelize.STRING,
  description: Sequelize.TEXT,
  deadline: Sequelize.DATE
})
```

你还可以对数据表中每一列进行详细的定义：

```javascript
const Foo = sequelize.define('foo', {
  // 初始化时，若未设置，则会被自动设置为 true
  flag: {
    type: Sequelize.BOOLEAN,
    allowNull: false,
    defaultValue: true
  },

  // 默认值设置为当前时间
  myDate: {
    type: Sequelize.DATE,
    defaultValue: Sequelize.NOW
  },

  // 设置 `allowNull` 为 `false`，则该列对应的数据列将会被设置为 `NOT NULL`，这表示
  // 当向数据插入数据时，若该列为 `NULL`，则会抛出异常，如果你想在数据插入数据库之前，先
  // 检测某一个值是否为 `NULL`，请查看 `validations` 章节
  title: {
    type: Sequelize.STRING,
    allowNull: false
  },

  // 若设置 `unique` 键为 `true`，则在创建两个具有相同的该值的对象时，会报错，若我们将
  // `unique` 键的值设置为相同的字符串值，则会形成一个复合唯一键，即这两个键不能出现任何
  // 一个相同的值。
  uniqueOne: {
    type: Sequelize.STRING,
    unique: 'compositeIndex'
  },
  uniqueTwo: {
    type: Sequelize.STRING,
    unique: 'compositeIndex'
  },

  // unique 属性也可以快速的被设置
  someUnique: {
    type: Sequelize.STRING,
    unique: true
  },
  // 上面的 someUnique 设置就是下面这样设置的快速方式：
  // someUnique: {
  //   type: Sequelize.STRING
  // },
  // indexes: [
  //   {
  //     unique: true,
  //     fields: [ 'someUnique' ]
  //   }

  // 设置主键
  identifier: {
    type: Sequelize.STRING,
    primaryKey: true
  },

  // 自增
  incrementMe: {
    type: Sequelize.INTEGER,
    autoIncrement: true
  },

  // 设置数据表字段名称（可以与模型对象中的字段名不一致
  fieldWithUnderscores: {
    type: Sequelize.STRING,
    field: 'field_with_underscores'
  },

  // 设置外键
  bar_id: {
    type: Sequelize.INTEGER,
    references: {
      // 关联至哪个模型
      model: Bar,
      // 当前键关联至被关联模型的那一个键
      key: 'id',
      // 是否在初始化时候横穿外键
      deferrable: Sequelize.Deferrable.INITIALLY_IMMEDIATE
    }
  }
})
```

`commont` 选项同样也可以在模型定义中使用，详细见模型配置章节。

## 数据类型

下面列举了一些常见的Sequelize支持的数据类型，详细列表请参考 [API 接口：数据类型章节](http://docs.sequelizejs.com/variable/index.html#static-variable-DataTypes)

```javascript
Sequelize.STRING                      // VARCHAR(255)
Sequelize.STRING(1234)                // VARCHAR(1234)
Sequelize.STRING.BINARY               // VARCHAR BINARY
Sequelize.TEXT                        // TEXT
Sequelize.TEXT('tiny')                // TINYTEXT

Sequelize.INTEGER                     // INTEGER
Sequelize.BIGINT                      // BIGINT
Sequelize.BIGINT(11)                  // BIGINT(11)

Sequelize.FLOAT                       // FLOAT
Sequelize.FLOAT(11)                   // FLOAT(11)
Sequelize.FLOAT(11, 12)               // FLOAT(11,12)

Sequelize.REAL                        // REAL        仅 PostgreSQL
Sequelize.REAL(11)                    // REAL(11)    仅 PostgreSQL
Sequelize.REAL(11, 12)                // REAL(11,12) 仅 PostgreSQL

Sequelize.DOUBLE                      // DOUBLE
Sequelize.DOUBLE(11)                  // DOUBLE(11)
Sequelize.DOUBLE(11, 12)              // DOUBLE(11,12)

Sequelize.DECIMAL                     // DECIMAL
Sequelize.DECIMAL(10, 2)              // DECIMAL(10,2)

Sequelize.DATE                        // mysql或者sqlite中为DATETIME，在postgres中为带时区的TIMESTAMP
Sequelize.DATE(6)                     // DATETIME(6) for mysql 5.6.4+. Fractional seconds support with up to 6 digits of precision
Sequelize.DATEONLY                    // DATE without time.
Sequelize.BOOLEAN                     // TINYINT(1)

Sequelize.ENUM('value 1', 'value 2')  // An ENUM with allowed values 'value 1' and 'value 2'
Sequelize.ARRAY(Sequelize.TEXT)       // Defines an array. PostgreSQL only.

Sequelize.JSON                        // JSON column. PostgreSQL only.
Sequelize.JSONB                       // JSONB column. PostgreSQL only.

Sequelize.BLOB                        // BLOB (bytea for PostgreSQL)
Sequelize.BLOB('tiny')                // TINYBLOB (bytea for PostgreSQL. Other options are medium and long)

Sequelize.UUID                        // UUID datatype for PostgreSQL and SQLite, CHAR(36) BINARY for MySQL (use defaultValue: Sequelize.UUIDV1 or Sequelize.UUIDV4 to make sequelize generate the ids automatically)

Sequelize.RANGE(Sequelize.INTEGER)    // Defines int4range range. PostgreSQL only.
Sequelize.RANGE(Sequelize.BIGINT)     // Defined int8range range. PostgreSQL only.
Sequelize.RANGE(Sequelize.DATE)       // Defines tstzrange range. PostgreSQL only.
Sequelize.RANGE(Sequelize.DATEONLY)   // Defines daterange range. PostgreSQL only.
Sequelize.RANGE(Sequelize.DECIMAL)    // Defines numrange range. PostgreSQL only.

Sequelize.ARRAY(Sequelize.RANGE(Sequelize.DATE)) // Defines array of tstzrange ranges. PostgreSQL only.

Sequelize.GEOMETRY                    // Spatial column.  PostgreSQL (with PostGIS) or MySQL only.
Sequelize.GEOMETRY('POINT')           // Spatial column with geometry type. PostgreSQL (with PostGIS) or MySQL only.
Sequelize.GEOMETRY('POINT', 4326)     // Spatial column with geometry type and SRID.  PostgreSQL (with PostGIS) or MySQL only.
```

`BLOB` 数据可以以字符或者 `buffer` 的类型写入，但是读出时，将永远都以 `buffer` 类型返回。

如果你使用的是PostgreSQL 的无时区 TIMESTAMP ，并且你需要将其转换成其它时区的值，可以使用 `pg` 自己的解析器：

```javascript
require('pg').types.setTypeParser(1114, stringValue => {
  return new Date(stringValue + '+0000')
})
```

在上面的数据类型中， `integer`、`bigint`、`float` 以及 `double` 这几种类型还支持 `unsigned` 以及 `zerofill` 属性，在添加时，也不需要考虑顺序。

```javascript
Sequelize.INTEGER.UNSIGNED              // INTEGER UNSIGNED
Sequelize.INTEGER(11).UNSIGNED          // INTEGER(11) UNSIGNED
Sequelize.INTEGER(11).ZEROFILL          // INTEGER(11) ZEROFILL
Sequelize.INTEGER(11).ZEROFILL.UNSIGNED // INTEGER(11) UNSIGNED ZEROFILL
Sequelize.INTEGER(11).UNSIGNED.ZEROFILL // INTEGER(11) UNSIGNED ZEROFILL
```

*上面的示例只展示了 `integer`，`bigint` 以及 `float` 的设置方法也一样。

对于  `enums`：

```javascript
sequelize.define('model', {
  states: {
    type: Sequelize.ENUM,
    values: ['active', 'pending', 'deleted']
  }
})
```

## Range 类型

由于 Range 类型需要定义包含/排除这样的额外信息，在JavaScript单纯使用一个元组并不能满足所有要求，以值的方式提供范围时，可以使用下面这些方法：

```javascript
// defaults to '["2016-01-01 00:00:00+00:00", "2016-02-01 00:00:00+00:00")'
// inclusive lower bound, exclusive upper bound
Timeline.create({ range: [new Date(Date.UTC(2016, 0, 1)), new Date(Date.UTC(2016, 1, 1))] });

// control inclusion
const range = [new Date(Date.UTC(2016, 0, 1)), new Date(Date.UTC(2016, 1, 1))];
range.inclusive = false; // '()'
range.inclusive = [false, true]; // '(]'
range.inclusive = true; // '[]'
range.inclusive = [true, false]; // '[)'

// or as a single expression
const range = [
  { value: new Date(Date.UTC(2016, 0, 1)), inclusive: false },
  { value: new Date(Date.UTC(2016, 1, 1)), inclusive: true },
];
// '("2016-01-01 00:00:00+00:00", "2016-02-01 00:00:00+00:00"]'

// composite form
const range = [
  { value: new Date(Date.UTC(2016, 0, 1)), inclusive: false },
  new Date(Date.UTC(2016, 1, 1)),
];
// '("2016-01-01 00:00:00+00:00", "2016-02-01 00:00:00+00:00")'

Timeline.create({ range });
```

需要注意的是，你收到的值 也将是下面这样的：

```javascript
// stored value: ("2016-01-01 00:00:00+00:00", "2016-02-01 00:00:00+00:00"]
range // [Date, Date]
range.inclusive // [false, true]
```

请确保你在序列化之前已经将其转换为一个可序列化的格式，否则数组的扩展属性将不能被序列化。

### 特殊案例

```javascript
// empty range:
Timeline.create({ range: [] }); // range = 'empty'

// Unbounded range:
Timeline.create({ range: [null, null] }); // range = '[,)'
// range = '[,"2016-01-01 00:00:00+00:00")'
Timeline.create({ range: [null, new Date(Date.UTC(2016, 0, 1))] });

// Infinite range:
// range = '[-infinity,"2016-01-01 00:00:00+00:00")'
Timeline.create({ range: [-Infinity, new Date(Date.UTC(2016, 0, 1))] });
```

## 暂缓执行（Deferrable）

当你定义了一个外键，在 PostgreSQL 中，你可以选择指定为暂缓执行类型，下面这些可选项可用：

```javascript
// Defer all foreign key constraint check to the end of a transaction
Sequelize.Deferrable.INITIALLY_DEFERRED

// Immediately check the foreign key constraints
Sequelize.Deferrable.INITIALLY_IMMEDIATE

// Don't defer the checks at all
Sequelize.Deferrable.NOT
```

最后一项是 PostgreSQL 默认项，它不允许你在一个事务中修改数据列的暂缓规则。

## Getters 与 Setters

我们可以在模型上定义 `object-property` 的 `getter` 与 `setter` 方法，这样可以对外部调用隐藏属性本身，而通过一种我们提供的方式去修改或者获取这类的属性的值。

Getter 与 Setter 可以通过下面两种方式设置 ：

1. 在某一个属性上设置 
2. 在模型的 `options` 中设置

**注意**：如果同时使用两种方式定义了 `getter` 与 `setter` ，那么定义在单个属性上的设置优先权更高。

### 在单个属性上定义

```javascript
const Employee = sequelize.define('employee', {
  name: {
    type: Sequelize.STRING,
    allowNull: false,
    get() {
      const title = this.getDataValue('title');
      // 'this' allows you to access attributes of the instance
      return this.getDataValue('name') + ' (' + title + ')';
    },
  },
  title: {
    type: Sequelize.STRING,
    allowNull: false,
    set(val) {
      this.setDataValue('title', val.toUpperCase());
    }
  }
});

Employee
  .create({ name: 'John Doe', title: 'senior engineer' })
  .then(employee => {
    console.log(employee.get('name')); // John Doe (SENIOR ENGINEER)
    console.log(employee.get('title')); // SENIOR ENGINEER
  })
```

### 在模型定义中定义

下面的代码片段展示了如何在模型的 `options` 选项上面设置， `fullName` 的 getter ，本身并不存在这个属性，但是我们在模型的 `options` 中的 `setterMethods` 与 `getterMethods` 中分别都设置了 `fullName()` 函数，这个时候，就可以通过 `fullName()` 来获取或者设置 `firstname` 与 `lastname`。

但是需要注意的是，如果在 `fullName()` 中访问 `firstname` 与 `lastname`，同样会触发这两个属性的 `getter` 方法，如果想访问原始数据，请使用 `getDataValue()` 方法。

```javascript
const Foo = sequelize.define('foo', {
  firstname: Sequelize.STRING,
  lastname: Sequelize.STRING
}, {
  getterMethods: {
    fullName() {
      return this.firstname + ' ' + this.lastname
    }
  },

  setterMethods: {
    fullName(value) {
      const names = value.split(' ');

      this.setDataValue('firstname', names.slice(0, -1).join(' '));
      this.setDataValue('lastname', names.slice(-1).join(' '));
    },
  }
});
```

### 工具类方法

要访问底层数据，请总是使用 `this.getDataValue()` 方法：

```javascript
/* a getter for 'title' property */
get() {
  return this.getDataValue('title')
}
```

要从底层设置数据，请总蛤歌坛 `this.setDataValue()` 方法：

```javascript
/* a setter for 'title' property */
set(title) {
  this.setDataValue('title', title.toString().toLowerCase());
}
```

## 校验

模型的校验，允许你对模型的每一个属性进行数据格式、内容以及继承性的校验，校验会在 `create`、`update` 以及 `save` 操作时，自动执行，你也可以在一个模型的实例上调用 `validate()` 方法手工触发模型的校验。

> 校验库来源于 [validator.js](https://github.com/chriso/validator.js)。

```javascript
const ValidateMe = sequelize.define('foo', {
  foo: {
    type: Sequelize.STRING,
    validate: {
      is: ["^[a-z]+$",'i'],     // will only allow letters
      is: /^[a-z]+$/i,          // same as the previous example using real RegExp
      not: ["[a-z]",'i'],       // will not allow letters
      isEmail: true,            // checks for poem format (foo@bar.com)
      isUrl: true,              // checks for url format (http://foo.com)
      isIP: true,               // checks for IPv4 (129.89.23.1) or IPv6 format
      isIPv4: true,             // checks for IPv4 (129.89.23.1)
      isIPv6: true,             // checks for IPv6 format
      isAlpha: true,            // will only allow letters
      isAlphanumeric: true,     // will only allow alphanumeric characters, so "_abc" will fail
      isNumeric: true,          // will only allow numbers
      isInt: true,              // checks for valid integers
      isFloat: true,            // checks for valid floating point numbers
      isDecimal: true,          // checks for any numbers
      isLowercase: true,        // checks for lowercase
      isUppercase: true,        // checks for uppercase
      notNull: true,            // won't allow null
      isNull: true,             // only allows null
      notEmpty: true,           // don't allow empty strings
      equals: 'specific value', // only allow a specific value
      contains: 'foo',          // force specific substrings
      notIn: [['foo', 'bar']],  // check the value is not one of these
      isIn: [['foo', 'bar']],   // check the value is one of these
      notContains: 'bar',       // don't allow specific substrings
      len: [2,10],              // only allow values with length between 2 and 10
      isUUID: 4,                // only allow uuids
      isDate: true,             // only allow date strings
      isAfter: "2011-11-05",    // only allow date strings after a specific date
      isBefore: "2011-11-05",   // only allow date strings before a specific date
      max: 23,                  // only allow values <= 23
      min: 23,                  // only allow values >= 23
      isCreditCard: true,       // check for valid credit card numbers

      // custom validations are also possible:
      isEven(value) {
        if (parseInt(value) % 2 != 0) {
          throw new Error('Only even values are allowed!')
          // we also are in the model's context here, so this.otherField
          // would get the value of otherField if it existed
        }
      }
    }
  }
});
```

需要注意的是，如果需要传递多个参数给内置的校验方法，参数必须被包裹在一个数组中，但是如果某一个内置校验方法本身接受的参数就是一个数组，比如 `isIn` 方法，这个时候，请传递给他一个只有一个元素的数据，该数组内的元素为一个真正需要传递给方尺校验方法的数组，比如 `[['one', 'two']]`。

如果要自定义错误消息，将传递给校验方法的参数设置为一个对象即可，比如：

```javascript
isInt: {
  msg: '必须输入一个整型数字`
}
```

或者使用 `args` 传递参数：

```javascript
isIn: {
  args: [['en', 'zh']],
  msg: '必须为 english 或者中文中的一种`
}
```

当你使用的是自定义校验方法时，错误消息就可以是你在 `throw new Error` 过程中抛出的任何字符串了。

查看 [validator.js 项目主页](https://github.com/chriso/validator.js) 了解更多 validator.js 的使用方法。

### 校验器与 `allowNull`

如果模型的某一个属性被设置成为了 `allowNull: true` ，并且该模型实例的该属性的值被设置为 `null`，那么该值的任何校验方法都不会被执行。

### 模型级别的校验

除开对字段进行单独的校验之外，我们还可以在字段校验完成之后，在模型级别进行校验，模型级别的校验会在模型上下文环境下执行：

```javascript
const Pub = Sequelize.define('pub', {
  name: { type: Sequelize.STRING },
  address: { type: Sequelize.STRING },
  latitude: {
    type: Sequelize.INTEGER,
    allowNull: true,
    defaultValue: null,
    validate: { min: -90, max: 90 }
  },
  longitude: {
    type: Sequelize.INTEGER,
    allowNull: true,
    defaultValue: null,
    validate: { min: -180, max: 180 }
  },
}, {
  validate: {
    bothCoordsOrNone() {
      if ((this.latitude === null) !== (this.longitude === null)) {
        throw new Error('Require either both latitude and longitude or neither')
      }
    }
  }
})
```

在上例中，如果一个 `Pub` 实例中，设置了 `latitude` 或者 `longitude` 中的一个，在调用 `instance.validate()` 方法之后，可能会抛出下面这样的错误：

```javascript
{
  'latitude': ['Invalid number: latitude'],
  'bothCoordsOrNone': ['Require either both latitude and longitude or neither']
}
```

## 配置

你可以配置 Sequelize 如何处理你的数据列名称：

```javascript
const Bar = sequelize.define('bar', { /* bla */ }, {
  // don't add the timestamp attributes (updatedAt, createdAt)
  timestamps: false,

  // don't delete database entries but set the newly added attribute deletedAt
  // to the current date (when deletion was done). paranoid will only work if
  // timestamps are enabled
  paranoid: true,

  // don't use camelcase for automatically added attributes but underscore style
  // so updatedAt will be updated_at
  underscored: true,

  // disable the modification of table names; By default, sequelize will automatically
  // transform all passed model names (first parameter of define) into plural.
  // if you don't want that, set the following
  freezeTableName: true,

  // define the table's name
  tableName: 'my_very_custom_table_name',

  // Enable optimistic locking.  When enabled, sequelize will add a version count attribute
  // to the model and throw an OptimisticLockingError error when stale instances are saved.
  // Set to true or a string with the attribute name you want to use to enable.
  version: true
})
```

如果希望 sequelize 来处理 `timestamps` ，但是却不需要使用所有的 `timstamps` 功能，即么你可以像下面这样的：

```javascript
const Foo = sequelize.define('foo',  { /* bla */ }, {
  // don't forget to enable timestamps!
  timestamps: true,

  // I don't want createdAt
  createdAt: false,

  // I want updatedAt to actually be called updateTimestamp
  updatedAt: 'updateTimestamp',

  // And deletedAt to be called destroyTime (remember to enable paranoid for this to work)
  deletedAt: 'destroyTime',
  paranoid: true
})
```

你还可以设置数据库引擎：

```javascript
const Person = sequelize.define('person', { /* attributes */ }, {
  engine: 'MYISAM'
})

// or globally
const sequelize = new Sequelize(db, user, pw, {
  define: { engine: 'MYISAM' }
})
```

最后，你还可以为数据表设置备注信息：

```javascript
const Person = sequelize.define('person', { /* attributes */ }, {
  comment: "I'm a table comment!"
})
```

## 导入

你可以将模型的定义保存在单个文件中，然后使用 `import` 方法导入至应用，Sequelize 会缓存导入，所以，你完全没有必要担心会导入两次同一个模型的定义。

```javascript
// in your server file - e.g. app.js
const Project = sequelize.import(__dirname + "/path/to/models/project")

// The model definition is done in /path/to/models/project.js
// As you might notice, the DataTypes are the very same as explained above
module.exports = (sequelize, DataTypes) => {
  return sequelize.define("project", {
    name: DataTypes.STRING,
    description: DataTypes.TEXT
  })
}
```

`import` 方法还可以接受一个 `callback` 函数：

```javascript
sequelize.import('project', (sequelize, DataTypes) => {
  return sequelize.define("project", {
    name: DataTypes.STRING,
    description: DataTypes.TEXT
  })
})
```

## 乐观锁

Sequelize 通过模型实例的版本计数，内置了对乐观锁的支持，但是默认该特性并未被启用，要启用该功能，可以在模型定义时，设置  `versions` 的值为 `true` 即可。

## 数据库同步

当我们创建一个新项目时，数据库表结构是需要跟我们的模型定义同步的，这个时候可以使用 `sync` 功能：

```javascript
// Create the tables:
Project.sync()
Task.sync()

// Force the creation!
Project.sync({force: true}) // this will drop the table first and re-create it afterwards

// drop the tables:
Project.drop()
Task.drop()

// event handling:
Project.[sync|drop]().then(() => {
  // ok ... everything is nice!
}).catch(error => {
  // oooh, did you enter wrong database credentials?
})
```

如果模型定义很多，单独控制每一个模型的会需要编写很多行代码，所以， Sequelize 还提供了快速的方法：

```javascript
// Sync all models that aren't already in the database
sequelize.sync()

// Force sync all models
sequelize.sync({force: true})

// Drop all tables
sequelize.drop()

// emit handling:
sequelize.[sync|drop]().then(() => {
  // woot woot
}).catch(error => {
  // whooops
})
```

因为 `sync({force: true})` 是很危险的操作，所以Sequelize提供了一个 `match` 方法，只有当 `match` 成功时，才执行：

```javascript
// This will run .sync() only if database name ends with '_test'
sequelize.sync({ force: true, match: /_test$/ });
```

## 扩展模型

因为 Sequelize Models 就是 ES6 的 `class` ，所以，你可以非常容易的扩展它们：

```javascript
const User = sequelize.define('user', { firstname: Sequelize.STRING });

// Adding a class level method
User.classLevelMethod = function() {
  return 'foo';
};

// Adding an instance level method
User.prototype.instanceLevelMethod = function() {
  return 'bar';
};
```

当然，你还可以像下面这样：

```javascript
const User = sequelize.define('user', { firstname: Sequelize.STRING, lastname: Sequelize.STRING });

User.prototype.getFullname = function() {
  return [this.firstname, this.lastname].join(' ');
};

// Example:
User.build({ firstname: 'foo', lastname: 'bar' }).getFullname() // 'foo bar'
```

## 索引

Sequelize 支持为模型添加索引，他们会在 `Model.sync()` 或者 `sequelize.sync()` 方法执行的过程中被创建：

```
sequelize.define('user', {}, {
  indexes: [
    // Create a unique index on poem
    {
      unique: true,
      fields: ['poem']
    },

    // Creates a gin index on data with the jsonb_path_ops operator
    {
      fields: ['data'],
      using: 'gin',
      operator: 'jsonb_path_ops'
    },

    // By default index name will be [table]_[fields]
    // Creates a multi column partial index
    {
      name: 'public_by_author',
      fields: ['author', 'status'],
      where: {
        status: 'public'
      }
    },

    // A BTREE index with a ordered field
    {
      name: 'title_index',
      method: 'BTREE',
      fields: ['author', {attribute: 'title', collate: 'en_US', order: 'DESC', length: 5}]
    }
  ]
})
```