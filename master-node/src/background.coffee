async = require 'async'

checkFrequency = 5000 # 5 seconds
maxConcurrentJobs = 2

#this is where the file gets fix gets done (or called)
fixFile = (file, done) ->
	console.log "BACKGROUND: attempting fix for: #{file.name}"
	#TODO: fix file

	#done('shit broke!')  # if there is an error, call this

	done() #success!

#define our file fixing queue
fixFileQueue = async.queue fixFile, maxConcurrentJobs

#this runs every once in a while to look for work to do
checkFileStatus = () ->
	console.log "BACKGROUND: checking files status"
	#TODO: get files to fix from db
	files = [
		{
			name: 'file1'
		},
		{
			name: 'file2'
		}
	]

	# then for each on that need's a fixin', call .push with the arguments and a callback to handle the error
	for file in files
		do (file) ->  #the 'do' is to re-bind the file variable (creates a scope)
			console.log "BACKGROUND: queueing fix job for: #{file.name}"
			fixFileQueue.push file, (err) ->
				#TODO: record the error


	setTimeout(checkFileStatus, checkFrequency)

setTimeout(checkFileStatus, 0) #fire up the loop

