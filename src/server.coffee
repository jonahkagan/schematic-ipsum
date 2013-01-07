express = require "express"
http = require "http"
_ = require "./underscoreExt"
winston = require "winston"
expressWinston = require "express-winston"
async = require "async"
cors = require "connect-xcors"

schema = require "./schema"

app = express()

console.log process.env.NODE_ENV
PUBDIR = __dirname +
  if process.env.NODE_ENV is "development"
  then "/../front/public"
  else "/public"
console.log PUBDIR

MAX_ITEMS = 50

# Config
app.set "name", "Schematic Ipsum"
app.set "port", process.env.PORT or 3000

# Middleware
app.use express.logger "dev"
app.use express.bodyParser()
app.use express.methodOverride()
app.use cors()
app.use express.static PUBDIR
app.use app.router

# Error middleware
#app.use expressWinston.errorLogger transports: [
#  new winston.transports.Console(json: true, colorize: true)]
app.use express.errorHandler()

# Define our routes
app.post "/", (req, res) ->
  async.waterfall [
    (done) ->
      if (not req.body?) or (_.isEmpty req.body)
        done "Request missing body, which should be JSON schema."
      else done null
  ,
    (done) ->
      req.query.n ?= 1
      req.query.n = parseInt req.query.n
      if not _.isNumber(req.query.n) 
        done "Query param \"n\" must be a number, you sent #{req.query.n}"
      else if not (req.query.n > 0 and req.query.n <= MAX_ITEMS)
        done "Query param \"n\" must be between 0 and #{MAX_ITEMS}"
      else done null
  ,
    (done) -> done schema.validate req.body # TODO optimize
  ,
    (done) -> schema.genIpsums req.body, req.query.n, done
  ],
    (err, ipsums) ->
      if err?
        console.error err
        res.send 400, err
      else
        #console.log "Generated ipsum:", ipsums
        response = if ipsums.length is 1 then ipsums[0] else ipsums
        res.send 200, JSON.stringify(response, {}, "  ")

http.createServer(app).listen app.get("port"), ->
  console.log "#{app.get "name"} listening on port #{app.get "port"}" 
