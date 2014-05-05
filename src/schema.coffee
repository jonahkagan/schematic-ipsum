_ = require "./underscoreExt"
async = require "async"
jsv = require("JSV").JSV
uuid = require "node-uuid"

data = require "./data"

MAX_NUMBER = 100
MIN_NUMBER = -100
MAX_ARRAY_LENGTH = 5

nonEmpty = (strs) -> _.filter strs, (s) -> s and s.trim() isnt ""
clean = (s) -> s?.trim()

gen =
  paragraphs: (n, done) ->
    data.paragraphs (err, paras) ->
      done err, _.takeCyclic(nonEmpty(paras), n).join("\n")

  # http://stackoverflow.com/questions/11761563/javascript-regexp-for-splitting-text-into-sentences-and-keeping-the-delimiter
  sentence: (done) ->
    gen.paragraphs 1, (err, para) ->
      sentences = nonEmpty para.match(/[^\.!\?]+[\.!\?]+/g)
      if _.isEmpty sentences
      then gen.sentence done
      else done err, clean _.randomFrom sentences

  word: (done) ->
    gen.sentence (err, sentence) ->
      words = sentence.split(" ")
      word = _.randomFrom nonEmpty words
      # Only allow word-y characters
      word = word.toLowerCase().replace /[^a-z\-]/g, ""
      if word is ""
      then gen.word done
      else done err, clean word

  name: (done) ->
    data.names (err, names) ->
      done err, clean _.randomFrom names

  title: (done) ->
    data.titles (err, titles) ->
      done err, clean _.randomFrom titles

  id: (done) ->
    done null, uuid.v4()

  image: (size, done) ->
    done null, 'http://hhhhold.com/' + size + "?" + _.randomInt(0, 16777215)

  ipsumString: (schema, done) ->
    genFun = switch schema.ipsum
      when "id" then gen.id
      when "name" then gen.name
      when "first name"
        (done) -> gen.name (err, name) -> done err, name.split(' ')[0]
      when "last name"
        (done) -> gen.name (err, name) -> done err, name.split(' ')[1..].join(' ')
      when "title" then gen.title
      when "word" then gen.word
      when "sentence" then gen.sentence
      when "paragraph" then (done) -> gen.paragraphs 1, done
      when "long" then (done) -> gen.paragraphs _.randomInt(1, 10), done
      when "small image" then (done) -> gen.image 's', done
      when "medium image" then (done) -> gen.image 'm', done
      when "large image" then (done) -> gen.image 'l', done
      else gen.sentence
    genFun done

  formattedString: (schema, done) ->
    ret = (s) -> done null, s
    suffix = -> _.randomFrom ["com", "org", "net", "edu", "xxx"]
    switch schema.format
      when "date-time"
        ret (new Date(_.randomInt 0, Date.now())).toISOString()
      #when "date"
      #when "time"
      #when "regex"
      when "color"
        # http://paulirish.com/2009/random-hex-color-code-snippets/
        ret "#" + _.randomInt(0, 16777215).toString(16)
      #when "style"
      when "phone"
        ret "(#{_.randomInt 0, 999}) #{_.randomInt 0, 999} #{_.randomInt 0, 9999}"
      when "uri"
        gen.word (err1, word1) ->
          gen.word (err2, word2) ->
            done (err1 or err2), "http://#{word1}.#{word2}.#{suffix()}"
      when "email"
        gen.name (err, name) ->
          gen.word (err2, word) ->
            name = name.toLowerCase().replace(/\s/g, "_")
            done (err or err2), "#{name}@#{word}.#{suffix()}"
      #when "ip-address"
      #when "ipv6"
      #when "host-name"
      else ret "String format #{schema.format} not supported"

  # Generates a string for a schema assumed to have type string.
  string: (schema, done) ->
    if schema.format?
    then gen.formattedString schema, (err, s) -> done err, clean s
    else gen.ipsumString schema, (err, s) -> done err, clean s

  # Generates a random number b/w max and min
  # TODO take into account params of schema
  number: (schema, rand, done) ->
    done null, rand MAX_NUMBER, MIN_NUMBER

  byEnum: (schema, done) ->
    if not _.isArray schema.enum
      done "Value for \"enum\" must be an array."
    if _.isEmpty schema.enum
      done "Array for \"enum\" must not be empty."
    else
      done null, _.randomFrom schema.enum

  byType: (schema, done) ->
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
        if schema.items?
          # TODO take into account length constraints
          async.map(
            [0.._.randomInt(0, MAX_ARRAY_LENGTH)]
            (i, done) -> gen.ipsum schema.items, done
            done)
        else
          done "Missing \"items\" schema for schema of type \"array\""
      when "any"
        done "Type \"any\" not supported."
      else
        done "Bad type: \"#{schema.type}\""

  # Generate a JSON object that matches the given schema filled with ipsum
  # text.
  ipsum: (schema, done) ->
    if !schema?
    then done "Needs schema"
    else if schema.enum?
    then gen.byEnum schema, done
    else gen.byType schema, done

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
  genIpsum: gen.ipsum
  genIpsums: gen.ipsums
