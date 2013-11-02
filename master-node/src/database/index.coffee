db = require './setup'
dbtypes = require 'sequelize'

#module exports
module.exports =
	DatabaseNode: db.define 'DatabaseNode',
		host: dbtypes.STRING
		port: dbtypes.INTEGER
		path: dbtypes.STRING

	QueryResult: db.define 'QueryResult',
		query: dbtypes.STRING
		resultDatabase: dbtypes.STRING
		ranOn: dbtypes.DATE

#auto-create tables
db.sync()
	.error (err) ->
		console.log 'Error trying to create tables: ' + err
