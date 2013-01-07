should = require "should"
t = require "testify"
_ = require "underscore"

jsv = require("JSV").JSV
env = jsv.createEnvironment "json-schema-draft-03" 

client = t.createJsonClient port: 3000

validate = (schema, data) ->
  report = env.validate data, schema
  if _.isEmpty report.errors
    null
  else
    console.error report.errors
    new Error report.errors

testSchema = (title, schema) ->
   it "#{title}", (done) ->
    client.post "/ipsum", schema, t.shouldNotErr (req, res, data) ->
      console.log "#{title} data", data
      should.exist data
      err = validate schema, data
      done err


describe "primitive:", ->
  testSchema "string", type: "string"
  testSchema "number", type: "number"
  testSchema "integer", type: "integer"
  testSchema "boolean", type: "boolean"
  testSchema "any", type: "any"

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
  testIpsum "name"
  testIpsum "first name"
  testIpsum "last name"
  testIpsum "word"
  testIpsum "title"
  testIpsum "sentence"
  testIpsum "paragraph"


describe "errors:", ->

  it "should error if not given a schema", (done) ->
    client.post "/ipsum", null, t.shouldErr done, 400

  it "should error if given an empty schema", (done) ->
    client.post "/ipsum", {}, t.shouldErr done, 400

  # TODO test more invalid schemas
  it "should error if given an invalid schema", (done) ->
    client.post "/ipsum", { type: 0 }, t.shouldErr done, 400
