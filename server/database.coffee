Sequelize = require 'sequelize'

sequelize = new Sequelize 'database', 'username', 'password',
	dialect: 'sqlite'
	storage: 'databases/master.db'


DatabaseNode = sequelize.define 'DatabaseNode',
	host: Sequelize.STRING
	port: Sequelize.INTEGER

module.exports.DatabaseNode = DatabaseNode