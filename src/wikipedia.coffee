nodeio = require "node.io"
moment = require "moment"
output = []

class Wikipedia extends nodeio.JobClass
  input: false
  run: -> 
    baseUrl = "http://en.wikipedia.org"
    featUrl = baseUrl + "/wiki/Wikipedia:Today%27s_featured_article/" +
      moment().format "MMMM_D[%2C]_YYYY"
    @getHtml featUrl, (err, $, data) =>
      @exit err if err

      # Find the link to the full article
      articlePath = $("div#mw-content-text p a").first().attribs.href
      @getHtml baseUrl + articlePath, (err, $, data) =>
        @exit err if err

        $("div#mw-content-text p").each (p) ->
          text = p.striptags
          text = text.replace /\[[0-9]+\]/g, ""
          output.push text
        @emit output

@class = Wikipedia
@job = new Wikipedia({timeout:10})
