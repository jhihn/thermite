express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
db = require './lib/database'

app = new express

#all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', __dirname + '/webclient/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

#temporay, start 2 internal nodes
dbnode = require '../db-node/index'
app.use '/node1', dbnode.getMiddleware 'var/node1.db'
app.use '/node2', dbnode.getMiddleware 'var/node2.db'

app.use require('stylus').middleware(__dirname + '/webclient/public')
app.use express.static path.join __dirname, 'webclient/public'
app.use '/scripts/underscore', express.static path.join __dirname, '../node_modules/underscore'

#development only
if 'development' == app.get('env')
  app.use express.errorHandler()

#routes
routes(app) #setup routes

#start
http.createServer(app).listen app.get('port'), () ->
  console.log 'Express server listening on port ' + app.get('port')

  db.DatabaseNode.create({
  		host: 'fake host'
	  	port: 1234
	  	path: '/your/mom'
  	})
  	.success ->
  		console.log '****** made a project, now we\'ll query for it'

  		db.DatabaseNode.find(where: { host: 'fake host' })
  			.success (nodeRecord) ->
  				console.log "***** found node record, host: #{nodeRecord.host}, port: #{nodeRecord.port}, path: #{nodeRecord.path}"
