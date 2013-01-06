_ = require "./underscoreExt"
nodeio = require "node.io"
moment = require "moment"
output = []

randomMoment = ->
  # Featured articles started around 2005
  moment _.randomInt (new Date(2005, 1, 1)).getTime(), Date.now()

baseUrl = "http://en.wikipedia.org"

class Wikipedia extends nodeio.JobClass
  input: false
  run: -> 
    featUrl = baseUrl + "/wiki/Wikipedia:Today%27s_featured_article/" +
      randomMoment().format "MMMM_D[%2C]_YYYY"
    #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/December_15%2C_2007"
    #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/August_10%2C_2007"
    #featUrl = "http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/January_1%2C_2006"
    console.log featUrl
    @getHtml featUrl, (err, $, data) =>
      @exit err if err

      # Find the link to the full article
      as = $("div#mw-content-text p b a")
      a = if _.isArray as then as.first() else as
      articleUrl = baseUrl + a.attribs.href
      @getHtml articleUrl, (err, $, data) =>
        @exit err if err

        $("div#mw-content-text p").each (p) ->
          text = p.striptags
          text = text.replace /\[[0-9]+\]/g, ""
          output.push text
        @emit output

@class = Wikipedia
@job = new Wikipedia({timeout:10})
