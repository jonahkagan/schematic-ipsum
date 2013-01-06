_ = require "./underscoreExt"
nodeio = require "node.io"
wikipedia = require "./wikipedia"

runJob = (job, done) ->
  nodeio.start job, {}, done, true

funs =
  paragraphs: (n, done) ->
    runJob wikipedia.job, (err, output) ->
      done err, _.take(output, n).join("\n")

module.exports = _.mapObjVals funs, (fun, name) ->
  (n, done) ->
    fun n, (err, result) ->
      if err? or result is ""
        fs.readFile "../backupData/#{name}" (err, str) ->
          done null, _.take(str.split("\n"), n).join("\n")
      else
        done null, result
