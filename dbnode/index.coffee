sqlite3 = require 'sqlite3'
express = require 'express'
http = require 'http'

module.exports.start = (port, path) ->
	db = new sqlite3.Database(path)

	app = new express

	app.set 'port', port

	app.use express.logger('dev')
	app.use express.bodyParser()

	app.post '/executeQuery', (req, res) ->
		console.log '/executeQuery'
		console.log "Body: #{req.body.queryText}"

		db.all req.body.queryText, (err, rows) ->
			if err
				console.log 'Error: ' +  err

				res.json
					error: err
			else
				console.log "Success, #{rows.length} row(s) found."
				res.json rows


	#development only
	if 'development' == app.get('env')
		app.use(express.errorHandler());

	http.createServer(app).listen app.get('port'), () ->
		console.log('Express server (thermite node) listening on port ' + app.get('port'))