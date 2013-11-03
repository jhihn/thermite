fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
uuid = require 'node-uuid'
zlib = require 'zlib'

storageLocation = 'var/files/'

#private
getFilePath = (fileId) ->
	if not fs.existsSync storageLocation
		fs.mkdirSync storageLocation

	path.join storageLocation, fileId

#public
receiveFile = (stream, callback) ->
	fileId = uuid.v4()
	filePath = getFilePath fileId

	diskDestination = fs.createWriteStream(filePath)
		.on 'error', (err) -> #error trying to save the file
			callback(err)

	compressor = zlib.createGzip()

	# send it to --> gzip --> disk (archive)
	stream
		.pipe(compressor)
		.pipe(diskDestination)

	# simultateously process into blocks (you can split streams)
	shasum = crypto.createHash 'sha1'

	stream
		.on 'data', (chunk) ->
			shasum.update chunk

		.on 'end', () ->
			sha1 = shasum.digest('hex')

			console.log "Completed file #{fileId}, sha1: #{sha1}"

			callback(null, "some return value")

		.on 'error', (err) ->
			callback(err, null)



#expose exports
module.exports.receiveFile = receiveFile