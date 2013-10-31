http = require 'http'
db = require '../database'
async = require 'async'
_ = require 'underscore'
core = require '../core' #thermite core
reduceOperations = require '../reduceOperations'

module.exports =
	index: (req, res) ->
		#get the names of off the opreations
		reduceNames = _.keys reduceOperations

		db.DatabaseNode.all().success (nodes) ->
			res.render 'index',
				title: 'Welcome'
				nodes: nodes
				reduceNames: reduceNames

	runQuery: (req, res, next) ->
		#get all nodes from master database
		db.DatabaseNode.all()
			.error (err) ->
				next err
			.success (nodes) ->
				core.runQuery nodes, req.body.queryText, req.body.script, req.body.reduceName, (err, results) ->
					if err
						next err
						return

					#show html page with results
					res.render 'queryResult',
						title: 'Results'
						data: results
						queryText: req.body.queryText
