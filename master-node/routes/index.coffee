query = require './query'
pipeline = require './pipeline'

module.exports = (app) ->
	app.get '/', query.index
	app.post('/runQuery', query.runQuery);
	app.post('/parsestatement', query.parseStatement);

	app.get '/pipeline', pipeline.index
