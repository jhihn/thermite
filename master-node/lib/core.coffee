db = require './database'
async = require 'async'
_ = require 'underscore'
http = require 'http'
ResultsMerger = require './resultsMerger'
QueryBuilder = require './queryBuilder'
sqlparser = require './sqlparser'

#hard-coded node list (for now)
nodes = [
	{
		host: 'localhost'
		port: process.env.PORT || 3000
		path: '/node1'
	},
	{
		host: 'localhost'
		port: process.env.PORT || 3000
		path: '/node2'
	}
]

#runQuery
#params
# nodes: an array of node objects representing the nodes to query, with host, port, path
# query: sqlite query
# cb: callback to call when we are done, or have encountered an error
exports.runQuery = (query, script, cb) ->

	console.log 'running query...'

	merger = new ResultsMerger
		queryText: query

	#extract query data from sql
	queryData = sqlparser.parse(query)

	queryBuilder = new QueryBuilder(query, queryData)

	nodeQuery = queryBuilder.buildDataNodeQuery()

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
				query: nodeQuery
				script: script

			request.end()

	async.parallel dbcalls, (err, results) ->
		if err
			cb err #sorry, pal.

		results = merger.complete() #tell the merger we are done and get results
		
		cb null, results
