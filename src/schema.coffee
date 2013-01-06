_ = require "underscore"
async = require "async"
jsv = require("JSV").JSV

env = jsv.createEnvironment "json-schema-draft-03" 
metaSchema = env.getDefaultSchema()# "http://json-schema.org/draft-03/schema"

MAX_NUMBER = 100
MIN_NUMBER = -100
MAX_ARRAY_LENGTH = 100

randomNum = (min, max) ->
  Math.random() * (max + min) + min

randomInt = (min, max) ->
  Math.floor randomNum min, max

# Generates a random number b/w max and min
# TODO take into account params of schema
genNumber = (schema, rand, done) ->
  done null, rand MAX_NUMBER, MIN_NUMBER

genFormattedString = (schema, done) ->
  done null,
    switch schema.format
      when "date-time"
        (new Date(randomInt 0, (new Date().getTime()))).toISOString()
      #when "date"
      #when "time"
      #when "regex"
      when "color"
        # http://paulirish.com/2009/random-hex-color-code-snippets/
        "#" + randomInt(0, 16777215).toString(16)
      #when "style"
      when "phone"
        "(#{randomInt 0, 999}) #{randomInt 0, 999} #{randomInt 0, 9999}"
      when "uri" # TODO
        "http://news.ycombinator.com"
      when "email"
        "notdoneyet@ipsum.com" # TODO
      #when "ip-address"
      #when "ipv6"
      #when "host-name"
      else "String format #{schema.format} not supported"

# Generates a string by scraping Wikipedia
genString = (schema, done) ->
  if schema.format?
    genFormattedString schema, done
  else
    done null, "TODO"
  #else
  #  switch schema.ipsumType
  #    when "name"
  #    #when "
      


# Generate a JSON object that matches the given schema filled with ipsum
# text.
genIpsum = (schema, done) ->
  switch schema.type
    when "boolean"
      done null, Math.random() > 0.5
    when "number"
      genNumber schema, randomNum, done
    when "integer"
      genNumber schema, randomInt, done
    when "string"
      genString schema, done
    when "object"
      async.map _.values(schema.properties), genIpsum, (err, ipsumVals) ->
        done err, _.object _.keys(schema.properties), ipsumVals
    when "array"
      # TODO take into account length constraints
      async.map(
        _.range(0, randomInt(0, MAX_ARRAY_LENGTH))
        (i, done) -> genIpsum schema.items, done
        done)
    else
      done null, "Dunno what to do for type #{schema.type}"

module.exports =

  # Check that this is a valid JSON schema by validating it against the
  # meta-schema.
  validate: (schema) ->
    report = env.validate schema, metaSchema
    #console.log "errors", report.errors
    if _.isEmpty report.errors then null else report.errors

  genIpsum: genIpsum
