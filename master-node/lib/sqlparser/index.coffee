sqlparser = require 'sql-parser'

module.exports.parse = (sqlText) ->
	tokens = sqlparser.lexer.tokenize(sqlText)
	sqlparser.parser.parse(tokens)