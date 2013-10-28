
#need something a little more flexible
options = 
	port: process.argv[2]
	dbPath: process.argv[3]

require('./thermite-node').start options.port, options.dbPath