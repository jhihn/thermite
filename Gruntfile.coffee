module.exports = (grunt) ->
	grunt.initConfig
		coffee:
			build:
				options:
					bare: true
					sourceMap: true
				expand: true
				cwd: 'master-node/src/'
				src: [ '**/*.coffee' ]
				dest: 'master-node/lib/'
				ext: '.js'

	grunt.loadNpmTasks "grunt-contrib-coffee"

	grunt.registerTask 'default', 'Try Logging', ->
		grunt.log.write('Running the default task')

