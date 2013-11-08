sqlite3 = require 'sqlite3'
express = require 'express'
http = require 'http'
database = require './database'
fs = require 'fs'
child = require 'child_process'

#use the supplied app host instead of creating your own
getMiddleware = (path) ->

	database.setup(path, app.get('port'), true)
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

	app.get 'getFileInfo', (req, res) ->
		options = path: '/fileInfo&fileId=' + req.query.fileId
			host: req.query.host
			port: req.query.port
 
		http.get options, (req1, res1) ->
			buffer = ''
			res.on 'data', (data) ->
				buffer += data
			res.on 'end', () ->
				fileInfo = JSON.parse(buffer)		
				db = new sqlite3.Database('db-node.sqlite3')
				stmt = db.prepare "INSERT OR REPLACE INTO Files (guid, path, name, sha1, type, dupe, keys, schema, group, sep) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
				stmt.run [fileInfo.guid, fileInfo.path, fileInfo.name, fileInfo.sha1, fileInfo.type, fileInfo.dupe, fileInfo.keys, fileInfo.schema, fileInfo.group, fileInfo.sep]
				stmt.finalize()
				
				stmt = db.prepare "INSERT OR REPLACE INTO FileBlocks (blockId, fileId, blockSha1, start, end, has) VALUES (?, ?, ?, ?, ?, 0)"
				for block in fileInfo.blocks					
					stmt.run [block.blockId, block.fileId, block.blockSha1, block.start, block.end]
					stmt.finalize()

	app.get 'getFileBlock', (req, res) ->
		options = path: '/fileBlock&fileId=' + req.query.fileId + "&blockId=" + req.query.blockId
			host: req.query.host
			port: req.query.port
		fileName = ''
		http.get options, (req1, res1) ->
			buffer = ''
			fileName = q.query.fileId + "_" + req.query.blockId + ".tmp"
			s = fs.createWriteStream tempname
			shasum = crypto.createHash 'sha1'
			res.on 'data', (data) ->
				shasum.update (data)
				s.write data
			res.on 'end', () ->
				blockSha1 = shasum.digest('hex')
				s.close()
				stmt = db.prepare "SELECT name, schema FROM Files WHERE guid=?"
				stmt.get [req.query.fileId], (err, row) ->
					dbname = file.name + "_" + req.query.blockId + ".sqlite3"
					# we bypass the normal API for an extremely fast bulk insert
					p = child.spawn "sqlite3", [dbname]
					p.stdin.write file.schema + ";\n"
					p.stdin.write ".seperator '" + sep + "'\n"
					p.stdin.write ".import " + fileName + " " + file.name + "\n"
					p.stdin.write ".quit\n"
					p.on 'exit', () ->
						minKeys = [] #we don't use these yet
						maxKeys = []
						db.run "INSERT OR REPLACE INTO FileBlocks (blockSha1, has) ('?', 1)", [blockSha1]
						fs.remove fileName
						reportOpts = host: req.query.host
							port: req.query.port
							path: '/registerFileBlock?fileId=' + q.query.fileId + "&blockId=" + req.query.blockId + "&nodeId" + nodeId + "&minKeys" + minKeys + "&maxKeys" + maxKeys
						report = http.get reportOpts
	
	return app

startServer = (port, path) ->
	app = new express

	app.set 'port', port

	app.use express.compress()
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
