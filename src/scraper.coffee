_ = require "./underscoreExt"
nodeio = require "node.io"
wikipedia = require "./wikipedia"

module.exports =

  paragraphs: (n, done) ->
    nodeio.start(wikipedia.job, {}, (err, output) ->
      done err, _.take(output, n).join("\n")
    , true)
