assert = require 'assert'
async = require 'async'
_ = require 'underscore'
debug = require('debug') 'mongoose-any-index:test/test.coffee'
mongoose = require 'mongoose'
{Db,Server} = require 'mongodb'
mongoose = require 'mongoose'
Schema   = mongoose.Schema
util = require 'util'
any_index = require '../index'

MONGO_TEST_DB = 'test-any-index'
MONGO_TEST_IP = '127.0.0.1'
MONGO_TEST_PORT = 27017

describe 'mongoose-any-index', ->
  before (done) ->
    debug "BEGIN #{__filename}"
    db = new Db(MONGO_TEST_DB, new Server(MONGO_TEST_IP, MONGO_TEST_PORT), {w:1})
    db.open (err) => db.dropDatabase (err) =>
      @db = new Db(MONGO_TEST_DB, new Server(MONGO_TEST_IP, MONGO_TEST_PORT), {w:1})
      @db.open done
  beforeEach () ->
    @connection = mongoose.createConnection MONGO_TEST_IP, MONGO_TEST_DB, MONGO_TEST_PORT

  it 'adds a schema with normal mongoose indexes', (done) ->
    Normal = new Schema
      email: { type: String, index: true, unique: true, required: true }
      tags: [{type: String}]
      data: { type: Schema.Types.Mixed }
    @connection.model 'Normal', Normal
    setTimeout () =>
      @db.indexInformation 'normals', {full:true}, (err, index_information) =>
        debug util.inspect(index_information)
        assert.deepEqual index_information, [
          v: 1
          key: { _id: 1 }
          ns: "#{MONGO_TEST_DB}.normals"
          name: '_id_'
        ,
          v: 1
          key: { email: 1 }
          unique: true
          ns: "#{MONGO_TEST_DB}.normals"
          name: 'email_1'
          background: true
          safe: null
        ]
        done()
    , 1000

  it 'adds a schema with custom indexes', (done) ->
    Awesome = new Schema
      email: { type: String, index: true, unique: true, required: true }
      tags: [{type: String}]
      data: { type: Schema.Types.Mixed }
    Awesome.plugin any_index, [
      { keys: { 'data.whatever_you_want': 1 }, options: { unique: true, sparse: true } }
    ]
    @connection.model 'Awesome', Awesome
    setTimeout () =>
      @db.indexInformation 'awesomes', {full:true}, (err, index_information) =>
        debug util.inspect(index_information)
        assert.deepEqual index_information, [
          v: 1
          key: { _id: 1 }
          ns: "#{MONGO_TEST_DB}.awesomes"
          name: '_id_'
        ,
          v: 1
          key: { email: 1 }
          unique: true
          ns: "#{MONGO_TEST_DB}.awesomes"
          name: 'email_1'
          background: true
          safe: null
        ,
          v: 1
          key: { 'data.whatever_you_want': 1 }
          unique: true
          ns: 'test-any-index.awesomes'
          name: 'data.whatever_you_want_1'
          sparse: true
          background: true
          safe: null
        ]
        done()
    , 1000

  it "adds a schema with different custom indexes, asserts that mongoose doesn't drop old indexes", (done) ->
    Awesome = new Schema
      email: { type: String, index: true, unique: true, required: true }
      tags: [{type: String}]
      data: { type: Schema.Types.Mixed }
    Awesome.plugin any_index, [
      { keys: { 'data.something_different': 1 }, options: { unique: true, sparse: true } }
    ]
    @connection.model 'Awesome', Awesome
    async.waterfall [
      (cb_wf) => setTimeout cb_wf, 1000
      (cb_wf) => @db.indexInformation 'awesomes', {full:true},  cb_wf
      (index_information, cb_wf) =>
        debug util.inspect(index_information)
        assert.deepEqual index_information, [
          v: 1
          key: { _id: 1 }
          ns: "#{MONGO_TEST_DB}.awesomes"
          name: '_id_'
        ,
          v: 1
          key: { email: 1 }
          unique: true
          ns: "#{MONGO_TEST_DB}.awesomes"
          name: 'email_1'
          background: true
          safe: null
        ,
          v: 1
          key: { 'data.whatever_you_want': 1 }
          unique: true
          ns: 'test-any-index.awesomes'
          name: 'data.whatever_you_want_1'
          sparse: true
          background: true
          safe: null
        ,
          v: 1
          key: { 'data.something_different': 1 }
          unique: true
          ns: 'test-any-index.awesomes'
          name: 'data.something_different_1'
          sparse: true
          background: true
          safe: null
        ]
        @connection.models.Awesome.fullEnsureIndexes cb_wf
      (cb_wf) => setTimeout cb_wf, 1000
      (cb_wf) => @db.indexInformation 'awesomes', {full:true},  cb_wf
      (index_information, cb_wf) =>
        debug util.inspect(index_information)
        assert.deepEqual index_information, [
          v: 1
          key: { _id: 1 }
          ns: "#{MONGO_TEST_DB}.awesomes"
          name: '_id_'
        ,
          v: 1
          key: { email: 1 }
          unique: true
          ns: "#{MONGO_TEST_DB}.awesomes"
          name: 'email_1'
          background: true
          safe: null
        ,
          v: 1
          key: { 'data.something_different': 1 }
          unique: true
          ns: 'test-any-index.awesomes'
          name: 'data.something_different_1'
          sparse: true
          background: true
          safe: null
        ]
        cb_wf()
      ], done
