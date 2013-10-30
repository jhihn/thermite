_ = require 'underscore'

# reduce operations

#results wll be an array, oeach object is the resutls form the query from one node.
#(that is probably an array, too

reduceOperations =

	#union operation. appends all the resutls together
	"union": (nodeResults, callback) ->
		reducedResults = _.union.apply null, nodeResults

		callback null, reducedResults #null = the error

	"count all": (nodeResults, callback) ->
		count = 0

		for nodeResult in nodeResults
			count += nodeResult.length

		callback null, [ count: count ]

#export!
module.exports = reduceOperations
