# mongoose-any-index

[Mongoose](http://mongoosejs.com) plugin that adds some additional functionality to mongoose indexes:

1. Lets you add arbitrary indexes to any path, regardless of whether it's specified in your schema. The typical case is when you want sparse indexes within a Mixed type:

    ```coffeescript
    Awesome = new Schema
      email: { type: String, index: true, unique: true, required: true }
      tags: [{type: String}]
      data: { type: Schema.Types.Mixed }
    Awesome.plugin any_index, [
      [ { 'data.nested_field': 1 }, { unique: true, sparse: true } ]
    ]
    ```

2. Adds a `Model.fullEnsureIndexes(cb)` static method that drops indexes not specified in your schema. This lets you avoid "index bloat", since mongoose's `Model.ensuresIndexes(cb)` by default does not call `dropIndex` on pre-existing indexes.

## Installation

```bash
npm install mongoose-any-index
```
