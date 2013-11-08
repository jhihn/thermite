express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
db = require './database'
cp =  require 'child_process'
fs = require 'fs'

app = new express

#all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join __dirname, '../webclient/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
#app.use express.compress()
app.use express.bodyParser({ limit: 1024 * 1024 * 1024 * 1024 })
app.use express.methodOverride()
app.use app.router

#temporay, start 2 internal nodes
#dbnode = require '../../db-node/index'
#app.use '/node1', dbnode.getMiddleware 'var/node1.db'
#app.use '/node2', dbnode.getMiddleware 'var/node2.db'

nodeProcesses = []
for nodeId in [0..4] 
	fs.existsSync 'var/node' + nodeId, (exists) ->
		if not exists
			fs.mkdir 'var/node' + nodeId, () ->
			
	console.log "Attempting to start local node: node" + nodeId
	p = cp.spawn 'node', ['dbnode.js', 3001 + nodeId, '/var/node' + nodeId ]
	nodeProcesses.push p



app.use require('stylus').middleware(path.join __dirname, '../webclient/public')
app.use express.static path.join __dirname, '../webclient/public'
app.use '/scripts/underscore', express.static path.join __dirname, '../../node_modules/underscore'
app.use '/scripts/dataflow', express.static path.join __dirname, '../../node_modules/dataflow'

#development only
if 'development' == app.get('env')
  app.use express.errorHandler()

#routes
routes(app) #setup routes

#start
http.createServer(app).listen app.get('port'), () ->
  console.log 'Express server (MASTER) listening on port ' + app.get('port')

	#db.DatabaseNode.create({
	#	host: 'fake host'
	#	port: 1234
 	#  	path: '/your/mom'
	#})
  	#.success ->
  	#	console.log '****** made a project, now we\'ll query for it'
    #
  	#	db.DatabaseNode.find(where: { host: 'fake host' })
  	#		.success (nodeRecord) ->
  	#			console.log "***** found node record, host: #{nodeRecord.host}, port: #{nodeRecord.port}, path: #{nodeRecord.path}"
