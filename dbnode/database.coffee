sqlite3 = require 'sqlite3'

module.exports = 
	setup: (path, createTestData) ->
		module.exports.database = new sqlite3.Database(path)
		
		if createTestData
			require './createsampledata'
		