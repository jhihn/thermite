# local master database. This is used for keeping config info or data about nodes, etc.
# NOT meant to store query results.

Sequelize = require 'sequelize'
fs = require 'fs'

#TESTING: delete master db each starup
if fs.existsSync 'var/master.db'
	fs.unlinkSync 'var/master.db'

sequelize = new Sequelize 'database', 'username', 'password',
	dialect: 'sqlite'
	storage: 'var/master.db'

logErrorsFrom = (x) ->
	x.error (err) ->
		console.log err
	x

#Defines a database node that we shoulds connect to.
DatabaseNode = sequelize.define 'DatabaseNode',
	host: Sequelize.STRING
	port: Sequelize.INTEGER
	path: Sequelize.STRING

#make sure table exists
logErrorsFrom DatabaseNode.sync()
	.done ->
		#poulate it with some default records for testing
		logErrorsFrom DatabaseNode.findOrCreate host: 'localhost', port: process.env.PORT || 3000, path: '/node1'
		logErrorsFrom DatabaseNode.findOrCreate host: 'localhost', port: process.env.PORT || 3000, path: '/node2'
		#logErrorsFrom DatabaseNode.findOrCreate host: 'localhost', port: 3001, path: ''
		#logErrorsFrom DatabaseNode.findOrCreate host: 'localhost', port: 3002, path: ''

#module exports
module.exports.DatabaseNode = DatabaseNode