http = require('http');
/*
 * GET home page.
 */

exports.index = (req, res) ->
	res.render 'index'

exports.runQuery = (req, res) ->
	reqOptions =
		host: 'localhost'
		port: 3001
		method: 'POST'
		path: '/executeQuery'

	http.request options, (response) ->
		data = '';
		response.on 'data', (chunk) ->
			data += chunk;

		response.on 'end', () ->
			res.render 'queryResult', data
