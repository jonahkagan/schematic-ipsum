fs = require "fs"
_ = require "../src/underscoreExt"
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

titles = (done) ->
  titleUrl = baseUrl + "/wiki/Wikipedia:Featured_article_candidates/Featured_log/" +
    randomMoment().format "MMMM_YYYY"
  console.log titleUrl
  scrape uri: titleUrl, (err, $) ->
    if err then return done err

    titles = []
    $("table#toc li.toclevel-2 span.toctext").each ->
      titles.push $(this).text()

    done null,
      titles: titles
      url: titleUrl
 
names = (done) ->
  nameUrl = baseUrl + "/wiki/" + randomMoment().format "MMMM_D"
  console.log nameUrl
  scrape uri: nameUrl, (err, $) ->
    if err then return done err

    names = []
    birthList = $("div#mw-content-text > ul")[1] # births
    $(birthList).find("li").each ->
      line = $(this).text()
      name = line.match(/\–([^,]+),/)?[1]
      names.push name if name?

    done null,
      names: names
      url: nameUrl

write = (path, text) ->
  fs.writeFile path, text, "utf8", (err) ->
    if err then console.error err else console.log "done writing #{path}"

writeResults = (msg, path, text) ->
  if (not text?) or (text is "")
    console.error "error scraping: #{msg}"
  else
    console.log "writing to #{path}"
    write path, text

name = (path) ->
  path[path.lastIndexOf("/") + 1..]

module.exports =
  scrapeArticles: (n, outPath) ->
    _.each [1..n], (i) ->
      randomFeatArticle (err, res) ->
        if err then return console.error err
        path = outPath + name res.url + ".txt"
        writeResults res.url, path, res.text

  scrapeTitles: (outPath) ->
    titles (err, res) ->
      if err then return console.error err
      path = outPath + name res.url + ".txt"
      writeResults res.url, path, titles.join("\n")

  scrapeNames: (outPath) ->
    names (err, res) ->
      if err then return console.error err
      path = outPath + name res.url + ".txt"
      writeResults res.url, path, names.join("\n")

#module.exports.scrapeArticles 10, "data/para/"
#module.exports.scrapeTitles "data/titles/"
#module.exports.scrapeNames "data/names/"
console.log "Scrapers are commented out"
