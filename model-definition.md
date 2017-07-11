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
