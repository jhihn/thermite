async = require 'async'
_ = require 'underscore'

module.exports = (db) ->

	rows = 10

	# prepare all the functions to call serially, part 1: DDL statements
	createCommands = [
		(done) -> db.run "DROP TABLE IF EXISTS TestData;", done
		(done) -> db.run "CREATE TABLE TestData (ColA INTEGER);", done
		]

	# prepare all the functions to call serially, part 2: INSERT statements
	insertCommands = 
		for i in [1..rows]
			(done) ->
				cola = Math.floor Math.random() * rows * 2
				db.run "INSERT INTO TestData (ColA) VALUES (#{cola})", done

	allCommands = _.union createCommands, insertCommands

	# fire off the commands, one at a time
	async.series allCommands, (err, results) ->
		if err
			console.log 'Error: ' + err
			return

		console.log 'Test data created.'
