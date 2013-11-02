http = require 'http'
async = require 'async'
_ = require 'underscore'
core = require '../lib/core' #thermite core
sqlparser = require '../lib/sqlparser'

module.exports =
	index: (req, res) ->
		res.render 'index',
			title: 'Welcome'

	runQuery: (req, res, next) ->
		core.runQuery req.body.query, req.body.script, (err, results) ->
			if err
				next err
				return

			console.log JSON.stringify results

			#show html page with results
			res.render 'queryResult',
				title: 'Results'
				data: results.data
				query: results.query

	parseStatement: (req, res) ->
		res.json sqlparser.parse req.body.query
