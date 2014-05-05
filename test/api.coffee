should = require "should"
t = require "testify"
_ = require "underscore"
ipsum = require "../bin/schema"

jsv = require("JSV").JSV
env = jsv.createEnvironment "json-schema-draft-03" 

#client = t.createJsonClient port: 3000

validate = (schema, data) ->
  report = env.validate data, schema
  if _.isEmpty report.errors
    null
  else
#    console.error report.errors
    new Error report.errors

testSchema = (title, schema, check) ->
  it "#{title}", (done) ->
    ipsum.genIpsums schema, 1, (error, data) ->
#      console.log "#{title} data", data
      data = data[0]
      should.exist data
      err = validate schema, data
      if check? then check data
      done err

describe "primitive:", ->
  testSchema "string", type: "string"
  testSchema "number", type: "number"
  testSchema "integer", type: "integer"
  testSchema "boolean", type: "boolean"

describe "object:", ->
  testSchema "empty",
    type: "object"
    properties: {}

  testSchema "age",
    type: "object"
    properties:
      age: type: "number"

  testSchema "age, alive",
    type: "object"
    properties:
      age: type: "number"
      alive: type: "boolean"

describe "array:", ->
  testSchema "number",
    type: "array"
    items: type: "number"

describe "nested:", ->

  testSchema "array of objects",
    type: "array"
    items:
      type: "object"
      properties:
        count: type: "number"

  testSchema "object with array",
    type: "object"
    properties:
      count: type: "number"
      comments:
        type: "array"
        items: type: "boolean"

describe "string format:", ->
  # TODO test these match the format
  testFmt = (f) -> testSchema f, { type: "string", format: f }
  testFmt "date-time"
  testFmt "color"
  testFmt "phone"
  testFmt "uri"
  testFmt "email"

describe "string ipsum:", ->
  # TODO test these are correct
  testIpsum = (i) -> testSchema i, { type: "string", ipsum: i }
  testIpsum "id"
  testIpsum "name"
  testIpsum "first name"
  testIpsum "last name"
  testIpsum "title"
  testIpsum "word"
  testIpsum "sentence"
  testIpsum "paragraph"
  testIpsum "long"
  testIpsum "small image"
  testIpsum "medium image"
  testIpsum "large image"

describe "multiple:", ->
  it "5 bools", (done) ->
    ipsum.genIpsums { type: "boolean" }, 5, (error, data) ->
#      console.log "5 bools data", data, typeof data
      should.exist data
      data.should.be.an.instanceOf Array
      data.should.have.property "length", 5
      done()

describe "enum:", ->
  testSchema "singleton", { enum: [1] }, (res) -> res is 1
  testSchema "strings",
    type: "string"
    enum: ["a", "b"]
  , (res) -> res is "a" or res is "b"

shouldError = (done) ->
  (error) ->
    should.exist error
    done()

describe "errors:", ->
  # TODO tests for ?n

  it "should error if not given a schema (null)", (done) ->
    ipsum.genIpsums null, 1, shouldError done

  it "should error if not given a schema (undefined)", (done) ->
    ipsum.genIpsums undefined, 1, shouldError done

  it "should error if given an empty schema", (done) ->
    ipsum.genIpsums {}, 1, shouldError done

  # TODO test more invalid schemas
  it "should error if given an invalid schema", (done) ->
    ipsum.genIpsums { type: 0 }, 1, shouldError done

  it "should error if given type any", (done) ->
    ipsum.genIpsums { type: "any" }, 1, shouldError done

  it "should error if given type array without items", (done) ->
    ipsum.genIpsums { type: "array" }, 1, shouldError done
