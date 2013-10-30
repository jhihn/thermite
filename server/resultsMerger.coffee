_ = require 'underscore'

class ResultsMerger
	@isDone: false
	@results: null
	@queryDetails: null

	#querydetails = object containing the details of the query like:
	#  queryText: original sql
	#  aggregates: columns to aggregate
	#  etc (to be determined)
	constructor: (queryDetails) ->
		@queryDetails = queryDetails
		@results = []

	#source = info about the node this data came from
	#data = a variable number of rows received
	receiveChunk: (source, data) =>
		if @isDone
			throw 'No more chunks from you, you already told me you were done.'

		@results = _.union @results, data


	#called when all chunks have been delivered
	complete: () =>
		@isDone = true

		return @results

#export this class from the module
module.exports = ResultsMerger
