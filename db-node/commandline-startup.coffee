#starts up a thermite node using commandline options

#need something a little more flexible, maybe try out "commander"
options = 
	port: process.argv[2]
	dbPath: process.argv[3]

require('./index').start options.port, options.dbPath