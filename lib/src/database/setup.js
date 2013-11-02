var Sequelize, fs, sequelize;

Sequelize = require('sequelize');

fs = require('fs');

sequelize = new Sequelize('database', 'username', 'password', {
  dialect: 'sqlite',
  storage: 'var/master.db'
});

module.exports = sequelize;
