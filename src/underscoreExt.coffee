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

  randomFrom: (list) ->
    list[_.randomInt 0, list.length]

  takeCyclic: (list, n) ->
    if _.isEmpty list then return []
    taken = _.take list, n
    if taken.length < n
      taken.concat _.takeCyclic list, n - taken.length
    else taken

module.exports = _
