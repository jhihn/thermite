query = require './query'
filesystem = require './filesystem'
pipeline = require './pipeline'

module.exports = (app) ->
	app.get '/', query.index
	app.get '/filesystem', filesystem.index
	app.post '/runQuery', query.runQuery
	app.post '/parsestatement', query.parseStatement
	app.post '/upload', filesystem.upload2

	app.get '/pipeline', pipeline.index
