_ = require "./underscoreExt"
async = require "async"
jsv = require("JSV").JSV

data = require "./data"

MAX_NUMBER = 100
MIN_NUMBER = -100
MAX_ARRAY_LENGTH = 5

gen =
  paragraphs: (n, done) ->
    data.paragraphs (err, paras) ->
      done err, _.takeCyclic(paras, n).join("\n").trim()

  # http://stackoverflow.com/questions/11761563/javascript-regexp-for-splitting-text-into-sentences-and-keeping-the-delimiter
  sentence: (done) ->
    gen.paragraphs 1, (err, para) ->
      sentences = para.match /[^\.!\?]+[\.!\?]+/g or []
      done err, _.randomFrom sentences

  word: (done) ->
    gen.sentence (err, sent) ->
      words = sent.split(" ")
      done err, _.randomFrom(words).toLowerCase()

  name: (done) ->
    # TODO
    done null, "Obi Wan Kenobi"

  title: (done) ->
    # TODO
    done null, "Star Wars"

  id: (done) ->
    # TODO
    done null, "A1234QF230948"

  ipsumString: (schema, done) ->
    genFun = switch schema.ipsum
      #when "id" # TODO
      when "name" then gen.name
      when "first name"
        (done) -> gen.name (err, name) -> done err, name.split(' ')[0]
      when "last name"
        (done) -> gen.name (err, name) -> done err, name.split(' ')[1..].join(' ')
      when "title" then gen.title
      when "word" then gen.word
      when "sentence" then gen.sentence
      when "paragraph" then (done) -> gen.paragraphs 1, done
      else (done) -> gen.paragraphs _.randomInt(1, 10), done
    genFun done

  formattedString: (schema, done) ->
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
  string: (schema, done) ->
    if schema.format?
      gen.formattedString schema, done
    else
      gen.ipsumString schema, done

  # Generates a random number b/w max and min
  # TODO take into account params of schema
  number: (schema, rand, done) ->
    done null, rand MAX_NUMBER, MIN_NUMBER

  # Generate a JSON object that matches the given schema filled with ipsum
  # text.
  ipsum: (schema, done) ->
    switch schema.type
      when "boolean"
        done null, Math.random() > 0.5
      when "number"
        gen.number schema, _.randomNum, done
      when "integer"
        gen.number schema, _.randomInt, done
      when "string"
        gen.string schema, done
      when "object"
        async.map _.values(schema.properties), gen.ipsum, (err, ipsumVals) ->
          done err, _.object _.keys(schema.properties), ipsumVals
      when "array"
        # TODO take into account length constraints
        async.map(
          [0.._.randomInt(0, MAX_ARRAY_LENGTH)]
          (i, done) -> gen.ipsum schema.items, done
          done)
      else
        done null, "Dunno what to do for type #{schema.type}"

  ipsums: (schema, n, done) ->
    async.map([0..n-1],
      (i, done) -> gen.ipsum schema, done
      done)

env = jsv.createEnvironment "json-schema-draft-03" 
metaSchema = env.findSchema "http://json-schema.org/draft-03/schema"

# Check that the input is a valid JSON schema by validating it against the
# meta-schema.
validate = (schema) ->
  report = env.validate schema, metaSchema
  #console.log "errors", report.errors
  if _.isEmpty report.errors then null else report.errors

module.exports =
  validate: validate
  genIpsums: gen.ipsums
