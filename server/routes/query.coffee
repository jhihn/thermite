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
				do (node) -> (done) ->
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
							#convert to js
							parsedData = JSON.parse(data)

							#add on virtual column so we know which dbnode it came from
							alteredData = for x in parsedData
								x['_node'] = "#{node.host}:#{node.port}"
								x

							done null, alteredData

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
					data: _.union.apply null, results
					queryText: req.body.queryText