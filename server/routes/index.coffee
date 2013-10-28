http = require 'http'

exports.index = (req, res) ->
	res.render 'index'

exports.runQuery = (req, res) ->
	console.log 'running query...'

	reqOptions =
		port: 3001
		method: 'POST'
		path: '/executeQuery'
		headers:
			'Content-Type': 'application/json'

	request = http.request reqOptions, (response) ->
		data = '';
		response.on 'data', (chunk) ->
			data += chunk;

		response.on 'end', () ->
			res.render 'queryResult', data: data

	request.on 'error', (err) ->
			res.render 'error', error: err


	request.write JSON.stringify
		queryText: req.body.queryText

	request.end()
