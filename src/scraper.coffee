fs = require "fs"
_ = require "./underscoreExt"
moment = require "moment"
quest = require "quest"
jsdom = require "jsdom"

scrape = (options, done) ->
  quest options, (err, response, body) ->
    if err? then return done err
    if response?.statusCode isnt 200
      return done "response.statusCode was #{response?.statusCode}"
    jsdom.env body,
      ["http://code.jquery.com/jquery.js"],
      (errs, window) ->
        if errs then done errs else done null, window.$

randomMoment = ->
  # Featured articles started around 2005
  moment _.randomInt (new Date(2005, 1, 1)).getTime(), Date.now()

baseUrl = "http://en.wikipedia.org"

wikiArticle = (url, done) ->
  console.log "scraping", url
  scrape uri: url, (err, $) ->
    if err then return done err

    paras = []
    $("div#mw-content-text p").each () ->
      text = $(this).text() # full text without html tags
      text = text.replace /\[[0-9]+\]/g, "" # replace ref text (e.g. [42])
      paras.push text

    done null,
      url: url
      text: paras.join("")

randomFeatArticle = (done) ->
  featUrl = baseUrl + "/wiki/Wikipedia:Today%27s_featured_article/" +
    randomMoment().format "MMMM_D[%2C]_YYYY"
  #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/December_15%2C_2007"
  #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/August_10%2C_2007"
  #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/January_1%2C_2006"
  scrape uri: featUrl, (err, $) ->
    if err then return done err
    # Find the link to the full article
    a = $("div#mw-content-text p b a")
    articleUrl = baseUrl + a.attr "href"
    wikiArticle articleUrl, done

n = 10
outPath = "data/para/"

name = (path) ->
  path[path.lastIndexOf("/") + 1..]

_.each [1..n], (i) ->
  randomFeatArticle (err, article) ->
    path = outPath + name article.url + ".txt"
    if err? or (not article.text?) or (article.text is "")
      console.error "error scraping #{path}"
      console.error err
    else
      console.log "writing to #{path}"
      fs.writeFile path, article.text, "utf8", (err) ->
        if err then console.error err else console.log "done writing #{path}"

#takeOffset = (list, n, offset) ->
#  taken = _.take _.rest(list, offset), n
#  if taken.length < n
#    taken.concat _.takeCyclic list, n - taken.length
#  else taken

#funs =

#fromBackup = (name, n, done) ->
#  fs.readFile "../backupData/#{name}" (err, str) ->
#    done null, _.takeCyclic(str.split("\n"), n).join("\n")

#module.exports = _.mapObjVals funs, (fun, name) ->
#  (n, done) ->
#    try 
#      fun n, (err, result) ->
#        if err? or result is ""
#          fromBackup name, n, done
#        else
#          done null, result
#    catch ex
#      fromBackup name, n, done
