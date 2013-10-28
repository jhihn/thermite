express = require 'express'
routes = require './routes'
user = require './routes/user'
http = require 'http'
path = require 'path'

app = new express

#all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require('stylus').middleware(__dirname + '/public')
app.use express.static path.join __dirname, 'public'

#development only
if 'development' == app.get('env')
  app.use express.errorHandler()

#routes
app.get('/', routes.index);
app.post('/runQuery', routes.runQuery);
app.get('/users', user.list);

#start
http.createServer(app).listen app.get('port'), () ->
  console.log 'Express server listening on port ' + app.get('port')

