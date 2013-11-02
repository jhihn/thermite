var db, dbtypes;

db = require('./setup');

dbtypes = require('sequelize');

module.exports = {
  DatabaseNode: db.define('DatabaseNode', {
    host: dbtypes.STRING,
    port: dbtypes.INTEGER,
    path: dbtypes.STRING
  }),
  QueryResult: db.define('QueryResult', {
    query: dbtypes.STRING,
    resultDatabase: dbtypes.STRING,
    ranOn: dbtypes.DATE
  })
};

db.sync().error(function(err) {
  return console.log('Error trying to create tables: ' + err);
});
