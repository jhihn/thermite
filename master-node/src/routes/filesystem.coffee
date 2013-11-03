db = require '../database'
crypto = require 'crypto'
fs = require 'fs'
uuid = require 'node-uuid'
  
module.exports =
	
	index: (req, res, next) ->

		db.FileTable.findAll()
			.success (files) ->
				# add a fake size property to the files
				files.forEach (file) -> file.size = 123456

				res.render 'filesystem',
					title: 'Welcome'
					files: files
			.error (err) ->
				next(err)
			
	upload: (req, res) ->
		#TODO: get this as chunks come in to the server and not after file upload is complete.
		console.log JSON.stringify req.files
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
						if c[0] == '"' || c[0] == "'"
							outColNames.push( c.substr(1, c.length-2) )
							out
						else
							outColNames.push( c )
					buffer = buffer.substr(x + 1)
					dataSize = 0
					headerDone = true						

			if dataSize > maxBlockSize
				i = buffer.rindex '\n'
				if i > -1				
					blocks.push offset - (buffer.length - i)
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
				colDefs.push outColNames[i] +' TEXT'
			createStatement += colDefs.join(', ') + ")"

			db.FileBlock.create
				fileId: fileId
				blockId: blockNum
				start: offset - (dataSize + i)
				end: offset - i				

			db.FileTable.create
				guid: fileId
				path: req.files.file.path
				name: req.files.file.name
				type: req.files.file.type 
				sha1: shasum.digest('hex')
				schema: createStatement
					

			res.redirect '/filesystem'
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
