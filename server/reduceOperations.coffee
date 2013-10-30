_ = require 'underscore'

# reduce operations

#results wll be an array, oeach object is the resutls form the query from one node.
#(that is probably an array, too

reduceOperations =

	#union operation. appends all the resutls together
	"union": (nodeResults, callback) ->
		reducedResults = _.union.apply null, nodeResults

		callback null, reducedResults #null = the error


	"unique column a": (nodeResults, callback) ->

		reducedResults = []

		for nodeResult in nodeResults
			mapResults = _.map nodeResult, (row) ->
				row.ColA

			#define a reduce function here to use in the call below
			reduceFunction = (memo, v) ->
				if (_.findWhere memo, ColA: v)
					memo #already exists
				else
					memo.push ColA: v #not there, add it

			reducedResults = _.reduce mapResults, reduceFunction, reducedResults

		callback null, reducedResults

	"count all": (nodeResults, callback) ->
		reduceFunction = (memo, v) -> memo + v.length

		count = _.reduce nodeResults, reduceFunction, 0

		callback null, [ count: count ]


#export!
module.exports = reduceOperations
