class QueryBuilder
	@queryDetails: null
	@originalQuery: null

	#querydetails = object containing the details of the query like
	constructor: (originalQuery, queryDetails) ->
		@originalQuery = originalQuery
		@queryDetails = queryDetails

	buildDataNodeQuery: () =>
		return @buildQuery(@queryDetails, false)

	buildMasterNodeQuery: () =>
		return @buildQuery(@queryDetails, true)

	buildQuery:(parsedQuery, master=False)->
		sql = 'SELECT '
		selColumns = []
		console.log(-1)
		for f in parsedQuery.fields
			alias = ' '
			nameOrFunc = ''
			if f.name
				alias += 'as ' + f.name.value 
				nameOrFunc = f.field.name 
			else 
				f.field.value 
			aliasCount = 0
			if nameOrFunc.toUpperCase() == 'AVG'
				console.log('a')
				if master	
					console.log('a1')				
					selColumns.push( 'SUM(_A' + aliasCount + ')/COUNT(_A' + (aliasCount + 1) + ')' )
					console.log('a11')
				else
					console.log('a2')
					selColumns.push( 'SUM(' + f.field.arguments[0].value + ') as _A' + aliasCount + ', COUNT(' + f.field.arguments[0].value + ') as _A' + (aliasCount + 1) )
					console.log('a22')
				aliasCount += 2
				console.log('b2')
			else if ['MIN', 'MAX', 'SUM', 'COUNT', 'TOTAL'].indexOf(nameOrFunc.toUpperCase()) != 0
				console.log('c')
				selColumns.push(nameOrFunc + '(' + f.field.name.value + ')' + alias)
			else
				console.log('d')
				selColumns.push(nameOrFunc + alias)
		
			sql += selColumns.join(', ')
		
		if parsedQuery.source 
			sql += 'FROM ' + parsedQuery.source.name.value 
		
		#if parsedQuery.where != null
		#	sql += ' WHERE '
		#	whereFields = []
		#	for f in f.where.fields
		#		groupFields.push(f.value )
		
		if parsedQuery.group
			sql += ' GROUP BY '
			groupFields = 
				for f in parsedQuery.group.fields
					f.value 
		console.log('aa')					
		sql += groupFields.join(', ')
		
		if parsedQuery.order
			sql += ' ORDER BY '
			orderFields = 
				for f in parsedQuery.order.orderings
					f.value.value + ' ' + f.direction
		console.log('bb')
		sql += ', '.join(orderFields)
		
		#if parsedQuery.limit != null
		#	sql += 'LIMIT '
		sql
	
#export this class from the module
module.exports = QueryBuilder

