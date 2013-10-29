http = require 'http'
db = require '../database'
async = require 'async'
_ = require 'underscore'

module.exports =
	index: (req, res) ->
		db.DatabaseNode.all().success (nodes) ->
			res.render 'index',
				title: 'Welcome'
				nodes: nodes

	runQuery: (req, res) ->
		console.log 'running query...'

		db.DatabaseNode.all().success (nodes) ->
			dbcalls = for node in nodes
				(done) ->
					reqOptions =
						host: node.host
						port: node.port
						method: 'POST'
						path: '/executeQuery'
						headers:
							'Content-Type': 'application/json'

					request = http.request reqOptions, (response) ->
						data = '';
						response.on 'data', (chunk) ->
							data += chunk;

						response.on 'end', () ->
							done null, JSON.parse(data)

					request.on 'error', (err) ->
						done err

					request.write JSON.stringify
						queryText: req.body.queryText

					request.end()

			async.parallel dbcalls, (err, results) ->
				if err
					res.render 'error',
						title: 'Error'
						error: err
					return

				res.render 'queryResult',
					title: 'Results'
					data: _.union results