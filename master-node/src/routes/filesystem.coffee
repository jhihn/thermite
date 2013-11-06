db = require '../database'
crypto = require 'crypto'
fs = require 'fs'
uuid = require 'node-uuid'
_ =  require 'underscore'
async =  require 'async'
  
module.exports =
	
	index: (req, res, next) ->
		db.con.query("SELECT guid, name, end as size, MAX(blockId) FROM Files F JOIN FileBlocks FB ON F.guid=FB.fileId GROUP BY guid ORDER BY name")
			.success (files) -> 
				commandFunctionList = for file in files
					(done) ->
						db.con.query("SELECT F.guid as guid, F.dupe as dupe, FB.blockId as blockId, onNodes FROM Files F JOIN FileBlocks FB ON F.guid=FB.fileId LEFT JOIN (SELECT fileId, blockId, COUNT(nodeId) as onNodes FROM FileBlockAllocations ) where onNodes < dupe AND guid='" + file.guid + "'")
							.success (blocks) -> 
								status = 'atdupefactor'
								for block in blocks
									if block.dupe > block.onNodes and status == 'atdupefactor'
										status = 'belowdupefactor'
									if block.onNodes == 0
										status = 'incomplete'
								file.status = status
								
								done(null,file)
							
							.error (err) ->
								done(err)																			

							
				async.series commandFunctionList, (err,files) ->
					if err
						next(err)
						return
				
					res.render 'filesystem',
						title: 'Welcome'
						files: files
		
			.error (err) ->
				next(err)

				
			
	upload: (req, res) ->
		#TODO: get this as chunks come in to the server and not after file upload is complete.
		createStatement = 'CREATE TABLE ' + req.files.file.name + ' (' 
		shasum = crypto.createHash 'sha1'
		maxBlockSize = Math.min 33554432, req.files.file.size
		dataSize = 0
		offset = 0
		headerDone = false
		sampleDone = false
		outColNames = []
		fileId = uuid.v4()
		blockNum = 0
		s = fs.ReadStream req.files.file.path
		buffer = ''
		sep = ''
		s.on 'data', (d) ->
			shasum.update d
			buffer += d
			dataSize += d.length
			offset += d.length
			console.log d.length
			if not headerDone
				x = buffer.indexOf('\n')
				if (x > 0)
				
					blockStart = x + 1
					colLine = buffer.substr(0, x + 1)
					tab = colLine.indexOf('\t')
					comma = colLine.indexOf('\t')
					sep = if tab > comma 
							'\t' 
						else 
							','
					cols = colLine.split(sep)					
					for c in cols
						c = c.trim()
						if c[0] == '"' || c[0] == "'"
							outColNames.push( c.substr(1, c.length-2) )
							out
						else
							outColNames.push( c )
					buffer = buffer.substr(x + 1)
					dataSize -= x + 1
					headerDone = true						

			if dataSize > maxBlockSize
				i = buffer.lastIndexOf '\n'
				if i > -1				
					dataSize = i + 1
					db.FileBlock.create
						fileId: fileId
						blockId: blockNum
						start: offset - (dataSize + i)
						end: offset - i				
					blockNum += 1
					
			if 	headerDone
				buffer = ''

		s.on 'end', () ->
			colDefs = []
			for i in [0..outColNames.length]
				colDefs.push outColNames[i] + ' TEXT'
			createStatement += colDefs.join(', ') + ")"

			db.FileBlock.create
				fileId: fileId
				blockId: blockNum
				start: offset - dataSize
				end: offset 

			db.File.create
				guid: fileId
				path: req.files.file.path
				name: req.files.file.name
				type: req.files.file.type 
				sha1: shasum.digest('hex')
				schema: createStatement
					

			res.redirect '/filesystem'
			
	fix: (req, res) ->
		#1 identify nodes needing blocks
		#2 send blocks to nodes
		fileMatch = ''
		if req.body.file.guid
			fileMatch = "F.guid = '" + req.body.file.guid + "'"
		db.con.query("SELECT F.guid as fileId, F.dupe, FB.blockId as blockId, onNodes FROM Files F JOIN FileBlocks FB ON F.guid=FB.fileId LEFT JOIN " +
		             "(SELECT fileId, blockId, COUNT(nodeId) as onNodes FROM FileBlockAllocations ) where oNodes < F.dupe " + fileMatch)
			.success(blocks) ->
				db.con.query "SELECT nodeId FROM DatabaseNodes"
					 .success(allNodes) ->
						for block in blocks
							db.con.query "SELECT nodeId from FileBlockAllocations WHERE fileId='"+ blocks.fileId+ "' and blockId='" + block.blockId + "'"
								.success(usedNodes) ->
									eligibleNodes = _.without allNodes,usedNodes
									if eligibleNodes.length > 0
										nodeIndex = _.random 0, eligibleNodes.length - 1
										sendFileBlockCommand eligibleNodes[nodeIndex], block.fileId, block.blockId
		
		res.redirect '/filesystem'
		
	sendFileInfo: (req, res) ->
		db.File.find({where: {guid: req.query.fileId}}) 
			.success (file) ->
				file = { guid: file.guid, name: file.name, group: file.group, dupe: file.dupe, schema: file.schema, sep: file.sep, sha1: file.sha1}
				file.blocks = []
				db.FileBlock.findAll({where: {'fileId': req.query.fileId}, order: 'blockId'}) 
					.success (blocks) ->
						for block in blocks
							block = { blockId: block.blockId, start: block.start, end: block.end, fileId: block.fileId, blockSha1: block.blockSha1 }
							file.blocks.push block						
						res.send JSON.stringify file
			
	sendFileBlock: (req, res) ->
		db.File.find({where: {guid: req.query.fileId}})
			.success (file) ->
				db.FileBlock.find({where: {fileId: req.query.fileId, blockId: req.query.blockId}})
					.success (fileBlock) ->
						s = fs.createReadStream file.path, {start: fileBlock.start, end: fileBlock.end}
						s.pipe res						
						res.end
					
				
###
{
  displayImage: {
    size: 11885,
    path: '/tmp/1574bb60b4f7e0211fd9ab48f932f3ab',
    name: 'avatar.png',
    type: 'image/png',
    lastModifiedDate: Sun, 05 Feb 2012 05:31:09 GMT,
    _writeStream: {
      path: '/tmp/1574bb60b4f7e0211fd9ab48f932f3ab',
      fd: 14,
      writable: false,
      flags: 'w',
      encoding: 'binary',
      mode: 438,
      bytesWritten: 11885,
      busy: false,
      _queue: [],
      drainable: true
    },
    length: [Getter],
    filename: [Getter],
    mime: [Getter]
  }
}
###
