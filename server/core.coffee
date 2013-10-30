db = require './database'
async = require 'async'
_ = require 'underscore'
http = require 'http'
reduceOperations = require './reduceOperations'
ResultsMerger = require './resultsMerger'

#core module

#runQuery
#params
# nodes: an array of node objects representing the nodes to query, with host, port, path
# query: sqlite query
# cb: callback to call when we are done, or have encountered an error
exports.runQuery = (nodes, query, reduceOperation, cb) ->

	console.log 'running query...'

	merger = new ResultsMerger
		queryText: query

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

					merger.receiveChunk(node, parsedData);

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

		results = merger.complete() #tell the merger we are done and get results
		
		cb null, results
