express = require "express"
http = require "http"
_ = require "underscore"

require "./underscoreExt"

schema = require "./schema"

app = express()

# Config
app.set "name", "Schematic Ipsum"
app.set "port", process.env.PORT or 3000

# Middleware
app.use express.logger "dev"
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

# Error middleware
app.use express.errorHandler()

# Define our routes
app.post "/ipsum", (req, res) ->
  if (not req.body?) or (_.isEmpty req.body)
    res.send 400, "Request missing body, which should be JSON schema."
  else
    #console.log "Got schema:", req.body
    err = schema.validate req.body # TODO optimize
    #console.log "Validation error:", err
    if err
      res.send 400, err
    else
      schema.genIpsum req.body, (err, ipsum) ->
        if err
          res.send 400, err
        else
          #console.log "Generated ipsum:", ipsum
          res.send 200, JSON.stringify ipsum

http.createServer(app).listen app.get("port"), ->
  console.log "#{app.get "name"} listening on port #{app.get "port"}" 
