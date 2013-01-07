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

scrapeWikiArticle = (done) ->
  featUrl = baseUrl + "/wiki/Wikipedia:Today%27s_featured_article/" +
    randomMoment().format "MMMM_D[%2C]_YYYY"
  #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/December_15%2C_2007"
  #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/August_10%2C_2007"
  #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/January_1%2C_2006"
  console.log featUrl

  scrape uri: featUrl, (err, $) ->
    if err then return done err

    # Find the link to the full article
    a = $("div#mw-content-text p b a")
    articleUrl = baseUrl + a.attr "href"
    console.log articleUrl

    scrape uri: articleUrl, (err, $) ->
      if err then return done err

      paras = []
      $("div#mw-content-text p").each () ->
        text = $(this).text() # full text without html tags
        text = text.replace /\[[0-9]+\]/g, "" # replace ref text (e.g. [42])
        paras.push text

      done null, paras

takeOffset = (list, n, offset) ->
  taken = _.take _.rest(list, offset), n
  if taken.length < n
    taken.concat _.takeCyclic list, n - taken.length
  else taken

funs =
  paragraphs: (n, done) ->
    scrapeWikiArticle (err, paras) ->
      done err, _.takeCyclic(paras, n).join("\n").trim()

  # http://stackoverflow.com/questions/11761563/javascript-regexp-for-splitting-text-into-sentences-and-keeping-the-delimiter
  sentences: (n, done) ->
    scrapeWikiArticle (err, paras) ->
      #console.log "OUTPUT", output
      sentences = paras.join(" ").match /[^\.!\?]+[\.!\?]+/g
      #console.log "SENTENCES", sentences
      nSents = takeOffset(sentences, n, _.randomInt(0, sentences.length))
      done err, nSents.join("").trim()

  names: (n, done) ->
    done null, "Obi Wan Kenobi"

  titles: (n, done) ->
    done null, "Star Wars"

module.exports = _.mapObjVals funs, (fun, name) ->
  (n, done) ->
    fun n, (err, result) ->
      if err? or result is ""
        fs.readFile "../backupData/#{name}" (err, str) ->
          done null, _.takeCyclic(str.split("\n"), n).join("\n")
      else
        done null, result
