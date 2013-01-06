_ = require "underscore"

_.mixin
  
  mapObjVals: (obj, f) ->
    _.foldl(obj, (acc, value, key, list) ->
      acc[key] = f value, key, list
      acc
    , {})

  randomNum: (min, max) ->
    Math.random() * (max - min) + min

  randomInt: (min, max) ->
    Math.floor _.randomNum min, max

module.exports = _
