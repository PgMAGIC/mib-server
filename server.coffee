connect = require("connect")
express = require("express")
io = require("socket.io")
_ = require("underscore")
QRCode = require('qrcode');
http = require('http')
dns = require('dns')
Q = require('q')
uuid =  require('uuid')

port = (process.env.PORT or 8081)

ipPromise = require('./serverInfo').getServerIp()

server = express()
httpServer = http.createServer(server)
httpServer.listen(port)

server.configure ->
  server.set "views", __dirname + "/views"
  server.set "view options",
    layout: false

  server.use connect.bodyParser()
  server.use express.cookieParser()
  server.use require('connect-assets')()
  server.use express.session(secret: "shhhhhhhhh!")
  server.use connect.static(__dirname + "/static")
  server.use server.router

server.locals._ = require("underscore")
server.use (err, req, res, next) ->
  if err instanceof NotFound
    res.render "404.jade",
      locals:
        title: "404 - Not Found"
        description: ""
        author: ""
        analyticssiteid: "XXXXXXX"

      status: 404

  else
    console.log err
    res.render "500.jade",
      locals:
        title: "The Server Encountered an Error"
        description: ""
        author: ""
        analyticssiteid: "XXXXXXX"
        error: err

      status: 500

io = io.listen(httpServer)

server.get "/", (req, res) ->
  # TODO: throw error
  throw new NotFound

server.get "/client-input/:id", (req, res) ->
  res.render "input_client.jade",
    locals=
      instanceInputId: req.params.id
      title: "Your Page Title"
      description: "Your Page Description"
      author: "Your Name"

server.get "/client-register", (req, res) ->
  id =  uuid.v4()
  res.send(id+"")

  channelname = "/mobileinput" + id 
  mChannel = io.of(channelname).on "connection", (socket) ->
    socket.on "input:set", (data) ->
      socket.broadcast.emit "input:set", data


server.get "/qrcode/:id", (req, res) ->
  ipPromise.then (add) ->
    QRCode.draw "http://"+add + ":" + port + "/client-input/" + req.params.id, (err, data)->
        data.pngStream().pipe(res)

server.get "/500", (req, res) ->
  throw new Error("This is a 500 Error")

NotFound = (msg) ->
  @name = "NotFound"
  Error.call this, msg
  Error.captureStackTrace this, arguments_.callee

ipPromise.then (add) ->
  console.log "Listening on http://"+add+":" + port