sqlite3 = require 'sqlite3'
express = require 'express'
http = require 'http'
database = require './database'

#use the supplied app host instead of creating your own
getMiddleware = (path) ->

	database.setup(path, true)
	db = database.database

	app = new express

	app.get '/', (req, res) ->
		res.end("dbnode running.")

	app.post '/executeQuery', (req, res) ->
		console.log '/executeQuery'
		console.log "Body: #{req.body.query}"

		db.all req.body.query, (err, rows) ->
			if err
				console.log 'Error: ' +  err

				res.json
					error: err
			else
				if req.body.script
					func = new Function('data', req.body.script)
					newRows = func(rows)

					#only replace "rows" with "newRows" if new rows is defined and not null
					if newRows
						rows = newRows

				console.log "Success, #{rows.length} row(s) found."
				res.json rows

	return app

startServer = (port, path) ->
	app = new express

	app.set 'port', port

	app.use express.logger('dev')
	app.use express.bodyParser()

	app.use getMiddleware path

	#development only
	if 'development' == app.get('env')
		app.use(express.errorHandler());

	http.createServer(app).listen app.get('port'), () ->
		console.log('Express server (thermite node) listening on port ' + app.get('port'))

module.exports.getMiddleware = getMiddleware
module.exports.start = startServer