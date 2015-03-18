module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON("package.json")
		harp:
			server:
				server: true
				source: './'
			dist:
				source: "./"
				dest: "build"
	# grunt.loadNpmTasks('grunt-contrib-uglify')

	grunt.loadNpmTasks('grunt-harp')
	grunt.registerTask('default', ['harp'])
