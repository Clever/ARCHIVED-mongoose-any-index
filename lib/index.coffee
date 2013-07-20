util = require 'util'
async = require 'async'
_ = require 'underscore'
debug = require('debug') 'mongoose-any-index:lib/index'

module.exports = (schema, options) ->
  _(options).each (index_spec) ->
    schema._indexes.push [index_spec.keys, index_spec.options]

  schema.statics.fullEnsureIndexes = (cb) ->
    async.waterfall [
      (cb_wf) => @ensureIndexes cb_wf
      (cb_wf) => @collection.indexInformation { full: true }, cb_wf
      (indexes, cb_wf) =>
        async.forEachSeries indexes, (index, cb_fe) =>
          # don't mess with _id index
          return cb_fe() if '_id' in _(index.key).keys()
          field = _(index.key).keys()[0]
          # if we can't find this key in our schema, remove it
          match = _(schema.indexes()).find (schema_index_spec) ->
            _(schema_index_spec[0]).isEqual index.key
          return cb_fe() if match?
          # https://jira.mongodb.org/browse/SERVER-9856 makes this unsafe
          console.log "no match for #{util.inspect(index)}, should be dropped"
          # @collection.dropIndex index.name, cb_fe
          cb_fe()
        , cb_wf
    ], cb
