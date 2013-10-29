async = require 'async'

module.exports = (db) ->

	rows = 10

	createCommands = [
		(done) -> db.run "DROP TABLE IF EXISTS TestData;", done
		(done) -> db.run "CREATE TABLE TestData (ColA INTEGER);", done
		]

	insertCommands = 
		for i in [1..rows]
			(done) ->
				cola = Math.floor Math.random() * rows * 2
				db.run "INSERT INTO TestData (ColA) VALUES (#{cola})", done

	async.series createCommands, (err, results) ->
		async.series insertCommands, (err, results) ->
			if err
				console.log 'Error: ' + err
				return

			console.log 'Test data created.'
