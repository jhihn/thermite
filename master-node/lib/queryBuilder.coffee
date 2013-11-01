class QueryBuilder
	@queryDetails: null
	@originalQuery: null

	#querydetails = object containing the details of the query like
	constructor: (originalQuery, queryDetails) ->
		@originalQuery = originalQuery
		@queryDetails = queryDetails

	buildDataNodeQuery: () =>
		return @originalQuery

	buildMasterNodeQuery: () =>
		return @originalQuery

#export this class from the module
module.exports = QueryBuilder
