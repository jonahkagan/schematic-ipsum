fs = require "fs"
_ = require "./underscoreExt"

paraFiles = _.map fs.readdirSync("data/para"), (f) -> "data/para/" + f

module.exports =

  paragraphs: (done) ->
    fs.readFile _.randomFrom(paraFiles), "utf8", (err, paraStr) ->
      done err, paraStr.split("\n")
