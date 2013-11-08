sqlite3 = require('sqlite3').verbose()
uuid = require 'node-uuid'

createSampleData = require './createsampledata'


module.exports = 
	setup: (path, port, createTestData) ->
		db = new sqlite3.Database(path)
		module.exports.database = db
		skipNodeInit = false
		nodedb = new sqlite3.Database path + 'db-node.sqlite3'
		#TODO: limit clients to specific masters. for development we don't use this
		nodedb.run "CREATE TABLE IF NOT EXISTS Masters (host TEXT, port INTEGER, PRIMARY KEY(host, port))"
		nodedb.run "CREATE TABLE DatabaseNodes (guid TEXT, host TEXT, port INTEGER, path TEXT, beat TEXT, nodeGroups TEXT, PRIMARY KEY(guid))",	(err) ->
			skipNodeInit = true
		if not skipNodeInit 
			nodedb.run "INSERT INTO DatabaseNodes (guid, host, port, path) VALUES (?, ?, ?, ?)", [uuid.v4(), '127.0.0.1', port, path]
		else
			nodedb.run "INSERT OR REPLACE INTO DatabaseNodes (port) VALUES (?)", [port]  #update our port (not assured to always be the same)
		
		#only masters listed will be spoken to, when not in development
		nodedb.run "INSERT OR REPLACE INTO Masters (host, port) VALUES ('localhost','3000')"
		nodedb.run "CREATE TABLE IF NOT EXISTS Files (guid TEXT, path TEXT, name TEXT, sha1 TEXT, type TEXT, dupe INTEGER DEFAULT 1, keys TEXT, schema TEXT, nodeGroups TEXT, sep TEXT PRIMARY KEY(guid))"
		nodedb.run "CREATE TABLE IF NOT EXISTS FileBlocks (fileId TEXT, blockId INTEGER, blockSha1 TEXT, start INTEGER, end INTEGER, has INTEGER DEFAULT 0, PRIMARY KEY(fileId, blockId))"
		
		if createTestData
			createSampleData db
		
