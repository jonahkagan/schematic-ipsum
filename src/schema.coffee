_ = require "underscore"
jsv = require("JSV").JSV
env = jsv.createEnvironment "json-schema-draft-03" 

metaSchema = env.getDefaultSchema()# "http://json-schema.org/draft-03/schema"

# Generate a JSON object that matches the given schema filled with ipsum
# text.
toIpsum = (schema) ->
  switch schema.type
    when "boolean" then Math.random() > 0.5
    when "number"
      Math.random() * 100
    when "integer"
      Math.round(Math.random() * 100)
    when "string"
      "TODO"
    when "object"
      _.mapObjVals schema.properties, toIpsum
    when "array"
      _.map _.range(0, Math.random() * 100), -> toIpsum schema.items
    when "any"
      "WTF"

module.exports =

  # Check that this is a valid JSON schema by validating it against the
  # meta-schema.
  validate: (schema) ->
    report = env.validate schema, metaSchema
    #console.log "errors", report.errors
    if _.isEmpty report.errors then null else report.errors

  toIpsum: (schema, done) -> done null, toIpsum schema
