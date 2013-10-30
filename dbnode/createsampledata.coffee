async = require 'async'
_ = require 'underscore'

firstNames = [
	'Jim'
	'Bob'
	'Joe'
]

lastNames = [
	'Smith'
	'Jones'
	'Simpson'
]

zipCodes = [
	'21030'
	'90210'
	'55555'
]

ageMin = 0
ageMax = 100

module.exports = (db) ->

	rows = 10

	# prepare all the functions to call serially, part 1: DDL statements
	createCommands = [
		(done) -> db.run "DROP TABLE IF EXISTS TestData;", done
		(done) -> db.run "CREATE TABLE TestData (FirstName TEXT, LastName TEXT, Age INTEGER, ZipCode TEXT);", done
		]

	# prepare all the functions to call serially, part 2: INSERT statements
	insertCommands = 
		for i in [1..rows]
			(done) ->
				firstName = firstNames[_.random 0, firstNames.length - 1]
				lastName = lastNames[_.random 0, lastNames.length - 1]
				zipCode = zipCodes[_.random 0, zipCodes.length - 1]
				age = _.random ageMin, ageMax
				db.run "INSERT INTO TestData (FirstName, LastName, Age, ZipCode) VALUES ('#{firstName}', '#{lastName}', #{age}, '#{zipCode}')", done

	allCommands = _.union createCommands, insertCommands

	# fire off the commands, one at a time
	async.series allCommands, (err, results) ->
		if err
			console.log 'Error: ' + err
			return

		console.log 'Test data created.'
