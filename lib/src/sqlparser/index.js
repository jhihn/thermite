var sqlparser;

sqlparser = require('sql-parser');

module.exports.parse = function(sqlText) {
  var tokens;
  tokens = sqlparser.lexer.tokenize(sqlText);
  return sqlparser.parser.parse(tokens);
};
