fs = require "fs"
_ = require "./underscoreExt"

filesInDir = (dir) -> _.map fs.readdirSync(dir), (f) -> dir + "/" +  f
paraFiles = filesInDir "data/paras"
nameFiles = filesInDir "data/names"
titleFiles = filesInDir "data/titles"

readFile = (files, done) ->
  fs.readFile _.randomFrom(files), "utf8", (err, contents) ->
    done err, contents.split("\n")

module.exports =
  paragraphs: (done) -> readFile paraFiles, done
  names: (done) -> readFile nameFiles, done
  titles: (done) -> readFile titleFiles, done
