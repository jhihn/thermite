# local master database. This is used for keeping config info or data about nodes, etc.
# NOT meant to store query results.

Sequelize = require 'sequelize'
fs = require 'fs'

#TESTING: delete master db each starup
#if fs.existsSync 'var/master.db'
#	fs.unlinkSync 'var/master.db'

sequelize = new Sequelize 'database', 'username', 'password',
	dialect: 'sqlite'
	storage: 'var/master.db'

module.exports = sequelize