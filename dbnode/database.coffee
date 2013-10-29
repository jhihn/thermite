sqlite3 = require 'sqlite3'
createSampleData = require './createsampledata'

module.exports = 
	setup: (path, createTestData) ->
		db = new sqlite3.Database(path)
		module.exports.database = db
		
		if createTestData
			createSampleData db
			
		