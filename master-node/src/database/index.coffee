db = require './setup'
dbtypes = require 'sequelize'

#module exports
module.exports =
	DatabaseNode: db.define 'DatabaseNode',
		host: dbtypes.STRING
		port: dbtypes.INTEGER
		path: dbtypes.STRING
		guid: dbtypes.STRING   
		beat: dbtypes.INTEGER  # last heartbeat time_t

	DatabaseNodeGroup: db.define 'DatabaseNodeGroup',
		name: dbtypes.STRING # name of group (ie. 'secret', 'open', 'jeff') for file block allocation
		guid: dbtypes.STRING # guid of node

	QueryResult: db.define 'QueryResult',
		query: dbtypes.STRING
		resultDatabase: dbtypes.STRING
		ranOn: dbtypes.DATE

	FileTable: db.define 'FileTable',
		guid: dbtypes.STRING						   # random GUID
		path: dbtypes.STRING                           # source file location (on master only)
		name: dbtypes.STRING                           # table name
		sha1: dbtypes.STRING                           # sha1 of file
		type: dbtypes.STRING						   # mime type (from upload)
		dupe: {type: dbtypes.INTEGER, defaultValue: 1} # -1 all nodes get the file, else n = n duplications
		keys: dbtypes.STRING                           # key cols (if set)
		schema: dbtypes.STRING                         # create table/index statements
		group: dbtypes.STRING                          # group the file belongs to


	#FileGroup:db.define 'FileTable',
	#	sha1: dbtypes.STRING                           # file SHA1
	#	group: dbtypes.STRING                          # group the file belongs to (more than 1 row means more than 1 group)

	FileBlock: db.define 'FileBlock',
		blockRowId: {type: dbtypes.INTEGER, autoIncrement: true}  # blockId  per cluster
		blockId: dbtypes.INTEGER  # blockId (0...n) per file
		fileId: dbtypes.STRING    # join to FileTable.guid
		blockSha1: dbtypes.STRING # sha1 for the raw block
		start: dbtypes.INTEGER    # starting offset in file
		end:   dbtypes.INTEGER    # ending offset in file

	FileBlockAllocation: db.define 'FileBlockAllocation',
		blockRowId: dbtypes.INTEGER
		blockId: dbtypes.INTEGER  # for a given blockid, we should have FileTable.dupe rows
		nodeId: dbtypes.STRING    # the node this block is on (join to DatbaseNode)
		minKeys: dbtypes.STRING   # min key in the block
		maxKeys: dbtypes.STRING   # max key in the block


	# USEFUL QUERIES
	# NodeListForFile (FileSha1): Select guid from DatabaseNodes JOIN DatabaseNodeGroup ON guid JOIN FileTable ON group WHERE sha1=FileSha1;
	# ReadyToQuery (fileSha1, now): Select blockId, nodeId from FileBlockAllocation JOIN DatabaseNode ON guid WHERE beat > now - 60

#auto-create tables
db.sync()
	.error (err) ->
		console.log 'Error trying to create tables: ' + err
