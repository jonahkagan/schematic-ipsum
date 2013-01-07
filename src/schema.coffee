_ = require "./underscoreExt"
async = require "async"
jsv = require("JSV").JSV

scraper = require "./scraper"

MAX_NUMBER = 100
MIN_NUMBER = -100
MAX_ARRAY_LENGTH = 5

# Generates a random number b/w max and min
# TODO take into account params of schema
genNumber = (schema, rand, done) ->
  done null, rand MAX_NUMBER, MIN_NUMBER

genFormattedString = (schema, done) ->
  done null,
    switch schema.format
      when "date-time"
        (new Date(_.randomInt 0, Date.now())).toISOString()
      #when "date"
      #when "time"
      #when "regex"
      when "color"
        # http://paulirish.com/2009/random-hex-color-code-snippets/
        "#" + _.randomInt(0, 16777215).toString(16)
      #when "style"
      when "phone"
        "(#{_.randomInt 0, 999}) #{_.randomInt 0, 999} #{_.randomInt 0, 9999}"
      when "uri" # TODO
        "http://news.ycombinator.com"
      when "email"
        "notdoneyet@ipsum.com" # TODO
      #when "ip-address"
      #when "ipv6"
      #when "host-name"
      else "String format #{schema.format} not supported"

# Generates a string for a schema assumed to have type string.
genString = (schema, done) ->
  if schema.format?
    genFormattedString schema, done
  else
    switch schema.ipsum
      when "name"
        scraper.names 1, done
      when "first name"
        scraper.names 1, (err, name) -> done err, name.split(' ')[0]
      when "last name"
        scraper.names 1, (err, name) -> done err, name.split(' ')[1..].join(' ')
      when "word"
        scraper.sentences 1, (err, sentence) ->
          words = sentence.split(" ")
          done err, words[_.randomInt(0, words.length)].toLowerCase()
      when "title"
        scraper.titles 1, done
      when "sentence"
        scraper.sentences 1, done
      when "paragraph"
        scraper.paragraphs 1, done
      else
        scraper.paragraphs _.randomInt(1, 10), done
      


# Generate a JSON object that matches the given schema filled with ipsum
# text.
genIpsum = (schema, done) ->
  switch schema.type
    when "boolean"
      done null, Math.random() > 0.5
    when "number"
      genNumber schema, _.randomNum, done
    when "integer"
      genNumber schema, _.randomInt, done
    when "string"
      genString schema, done
    when "object"
      async.map _.values(schema.properties), genIpsum, (err, ipsumVals) ->
        done err, _.object _.keys(schema.properties), ipsumVals
    when "array"
      # TODO take into account length constraints
      async.map(
        _.range(0, _.randomInt(0, MAX_ARRAY_LENGTH))
        (i, done) -> genIpsum schema.items, done
        done)
    else
      done null, "Dunno what to do for type #{schema.type}"

env = jsv.createEnvironment "json-schema-draft-03" 
metaSchema = env.getDefaultSchema()# "http://json-schema.org/draft-03/schema"

# Check that the input is a valid JSON schema by validating it against the
# meta-schema.
validate = (schema) ->
    report = env.validate schema, metaSchema
    #console.log "errors", report.errors
    if _.isEmpty report.errors then null else report.errors

module.exports =
  validate: validate
  genIpsum: genIpsum
