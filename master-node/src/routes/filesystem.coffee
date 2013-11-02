db = require '../database'
crypto = require 'crypto'
fs = require 'fs'
  
module.exports =
	
	index: (req, res) ->
		res.render 'filesystem',
			title: 'Welcome'
	upload: (req, res) ->
		#TODO: get this as chunks come in to the server and not after file upload is complete.
		console.log JSON.stringify req.files
		createStatement = 'CREATE TABLE ' + req.files.file.name + ' (' 
		shasum = crypto.createHash 'sha1'
		blockingsize = Math.min 33554432, req.files.file.size
		blockSize = 0
		offset = 0
		headerDone = false
		sampleDone = false
		outColNames = []

		offsets = []
		s = fs.ReadStream req.files.file.path
		buffer = ''
		sep = ''
		s.on 'data', (d) ->
			shasum.update d
			buffer += d

			if not headerDone
				x = buffer.indexOf('\n')
				if (x > 0)
					offset = x + 1
					offsets.push(offset)
					colLine = buffer.left(x + 1)
					tab = colLine.indexOf('\t')
					comma = colLine.indexOf('\t')
					sep = if tab > comma '\t' else ','
					cols = colLine.split(sep)					
					for c in cols
						if c[0] == '"' || c[0] == "'"
							outColNames.push( c.substr(1, c.length-2) )
							out
						else
							outColNames.push( c )
					buffer = buffer.substr(x + 1)
					headerDone = true
						
			dataSize += buffer.length
			offset += buffer.length 
			if dataSize > blockingSize
				i = buffer.rindex '\n'
				if i > -1				
					blocks.push offset - (buffer.length - i)
					dataSize = i + 1
			if 	headerDone
				buffer = ''

		s.on 'end', () ->
			colDefs = []
			for i in [0..outColNames.length]
				colDefs.push outColNames[i] + ' ' + outColTypes[i]
			createStatement += colDefs.join(' TEXT,') + ")"
			db.FileTable.create({
				path: req.files.file.path
				name: req.files.file.name
				type: req.files.file.type 
				sha1: shasum.digest('hex')
				schema: createStatement
			})		
			for i in [0..blocks.count - 1]
				db.FileTableBlocks.create
					sha1: shasum.digest('hex')
					blockId: i
					start: offsets[i] 
					end: offsets[i + 1] - 1
			
				
			db.FileTableBlocks.create
				sha1: shasum.digest('hex')
				blockId: blocks.count - 1
				start: offsets[offsets.length - 1] 
				end:  req.files.file.size
			

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
