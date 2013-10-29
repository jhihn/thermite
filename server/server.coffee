express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'

#temporary, internally hosted nodes
dbnode = require '../dbnode'

app = new express

#all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

#temporay, start 2 internal nodes
dbnode.startHosted 'node1', app, 'databases/node1.db'
dbnode.startHosted 'node2', app, 'databases/node2.db'

app.use require('stylus').middleware(__dirname + '/public')
app.use express.static path.join __dirname, 'public'

#development only
if 'development' == app.get('env')
  app.use express.errorHandler()

#routes
routes(app) #setup routes

#start
http.createServer(app).listen app.get('port'), () ->
  console.log 'Express server listening on port ' + app.get('port')

