db = require './database'
async = require 'async'
_ = require 'underscore'
http = require 'http'

#core module

#runQuery
#params
# nodes: an array of node objects representing the nodes to query, with host, port, path
# query: sqlite query
# cb: callback to call when we are done, or have encountered an error
exports.runQuery = (nodes, query, cb) ->

	console.log 'running query...'

	db.DatabaseNode.all().success (nodes) ->
		dbcalls = for node in nodes
			do (node) -> (done) ->
				reqOptions =
					host: node.host
					port: node.port
					method: 'POST'
					path: node.path + '/executeQuery'
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
							x['_node'] = "#{node.host}:#{node.port}#{node.path}"
							x

						done null, alteredData

				request.on 'error', (err) ->
					done err

				request.write JSON.stringify
					queryText: query

				request.end()

		async.parallel dbcalls, (err, results) ->
			if err
				cb err #sorry, pal.

			#success, reduce results and return them
			reducedResults = _.union.apply null, results #placeholder for more reduces

			cb null, reducedResults
