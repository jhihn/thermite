query = require './query'
filesystem = require './filesystem'
pipeline = require './pipeline'

module.exports = (app) ->
# index
	app.get '/', query.index

# filesystem
	app.get '/fileInfo', filesystem.sendFileInfo
	app.get '/fileBlock', filesystem.sendFileBlock
	app.get '/filesystem', filesystem.index
	app.post '/fix', filesystem.fix
	app.post '/upload', filesystem.upload

# query
	app.get '/pipeline', pipeline.index
	app.post '/runQuery', query.runQuery
	app.post '/parsestatement', query.parseStatement

