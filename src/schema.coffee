_ = require "underscore"
async = require "async"
jsv = require("JSV").JSV

env = jsv.createEnvironment "json-schema-draft-03" 
metaSchema = env.getDefaultSchema()# "http://json-schema.org/draft-03/schema"

MAX_NUMBER = 100
MIN_NUMBER = -100
MAX_ARRAY_LENGTH = 100

# Generates a random number b/w max and min
random = (max, min) ->
  Math.random() * (max + min) + min

# Generate a JSON object that matches the given schema filled with ipsum
# text.
toIpsum = (schema, done) ->
  ret = (res) -> done null, res
  switch schema.type
    when "boolean"
      ret Math.random() > 0.5
    when "number"
      ret random MAX_NUMBER, MIN_NUMBER
    when "integer"
      ret Math.round random MAX_NUMBER, MIN_NUMBER
    when "string"
      done null, "TODO"
    when "object"
      async.map _.values(schema.properties), toIpsum, (err, ipsumVals) ->
        done err, _.object _.keys(schema.properties), ipsumVals
    when "array"
      async.map(
        _.range(0, Math.random() * MAX_ARRAY_LENGTH)
        (i, done) -> toIpsum schema.items, done
        done)
    when "any"
      ret "WTF"

module.exports =

  # Check that this is a valid JSON schema by validating it against the
  # meta-schema.
  validate: (schema) ->
    report = env.validate schema, metaSchema
    #console.log "errors", report.errors
    if _.isEmpty report.errors then null else report.errors

  toIpsum: toIpsum
