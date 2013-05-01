(function() {
  var async, debug, util, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  util = require('util');

  async = require('async');

  _ = require('underscore');

  debug = require('debug')('mongoose-any-index:lib/index');

  module.exports = function(schema, options) {
    schema._indexes = schema._indexes.concat(options);
    return schema.statics.fullEnsureIndexes = function(cb) {
      var _this = this;

      return async.waterfall([
        function(cb_wf) {
          return _this.ensureIndexes(cb_wf);
        }, function(cb_wf) {
          return _this.collection.indexInformation({
            full: true
          }, cb_wf);
        }, function(indexes, cb_wf) {
          return async.forEachSeries(indexes, function(index, cb_fe) {
            var field, match;

            if (__indexOf.call(_(index.key).keys(), '_id') >= 0) {
              return cb_fe();
            }
            field = _(index.key).keys()[0];
            match = _(schema.indexes()).find(function(schema_index_spec) {
              return _(schema_index_spec[0]).isEqual(index.key);
            });
            if (match != null) {
              return cb_fe();
            }
            debug("no match for " + (util.inspect(index)));
            return _this.collection.dropIndex(index.name, cb_fe);
          }, cb_wf);
        }
      ], cb);
    };
  };

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/