Sequelize = require 'sequelize'

sequelize = new Sequelize 'database', 'username', 'password',
	dialect: 'sqlite'
	storage: 'databases/master.db'

logErrorsFrom = (x) ->
	x.error (err) ->
		console.log err
	x

#Defines a database node that we shoulds connect to.
DatabaseNode = sequelize.define 'DatabaseNode',
	host: Sequelize.STRING
	port: Sequelize.INTEGER

#make sure table exists
logErrorsFrom DatabaseNode.sync()
	.done ->
		#poulate it with some default records for testing
		logErrorsFrom DatabaseNode.findOrCreate host: 'localhost', port: 3001
		logErrorsFrom DatabaseNode.findOrCreate host: 'localhost', port: 3002		

#module exports
module.exports.DatabaseNode = DatabaseNode