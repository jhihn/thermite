sqlite3 = require 'sqlite3'
express = require 'express'
http = require 'http'

module.exports.start = (port, path) ->
	db = new sqlite3.Database(path)

	app = new express

	app.set 'port', port

	app.use(express.bodyParser());

	app.get '/executeQuery', (req, res) ->
		db.run(req.body.queryText)

	http.createServer(app).listen app.get('port'), () ->
		console.log('Express server (thermite node) listening on port ' + app.get('port'))