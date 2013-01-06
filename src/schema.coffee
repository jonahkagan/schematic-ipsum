_ = require "underscore"
async = require "async"
jsv = require("JSV").JSV

env = jsv.createEnvironment "json-schema-draft-03" 
metaSchema = env.getDefaultSchema()# "http://json-schema.org/draft-03/schema"

# Generate a JSON object that matches the given schema filled with ipsum
# text.
toIpsum = (schema, done) ->
  ret = (res) -> done null, res
  switch schema.type
    when "boolean"
      ret Math.random() > 0.5
    when "number"
      ret Math.random() * 100
    when "integer"
      ret Math.round(Math.random() * 100)
    when "string"
      done null, "TODO"
    when "object"
      async.map _.values(schema.properties), toIpsum, (err, ipsumVals) ->
        done err, _.object _.keys(schema.properties), ipsumVals
    when "array"
      async.map(
        _.range(0, Math.random() * 100)
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
