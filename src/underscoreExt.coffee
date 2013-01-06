_ = require "underscore"

_.mixin
  
  mapObjVals: (obj, f) ->
    _.foldl(obj, (acc, value, key, list) ->
      acc[key] = f value, key, list
      acc
    , {})
