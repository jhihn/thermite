Sequelize = require 'sequelize'

sequelize = new Sequelize 'database', 'username', 'password',
	dialect: 'sqlite'
	storage: 'databases/master.db'


DatabaseNode = sequelize.define 'DatabaseNode',
	host: Sequelize.STRING
	port: Sequelize.INTEGER

DatabaseNode.sync()

DatabaseNode.findOrCreate host: 'localhost', port: 3001
DatabaseNode.findOrCreate host: 'localhost', port: 3002

module.exports.DatabaseNode = DatabaseNode