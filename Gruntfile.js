module.exports = function(grunt) {

	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),

		coffee: {
			compile: {
				expand: true,
				flatten: true,
				cwd: 'src',
				src: ['*.coffee'],
				dest: 'bin',
				ext: '.js'
			}
		},

		simplemocha: {
			options: {
				timeout: 5000,
				ignoreLeaks: true,
				grep: '',
				reporter: 'spec',
				compilers: ['coffee:coffee-script']
			},

			all: { src: ['test/**/*.coffee'] }
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-simple-mocha');

	// Default task(s).
	grunt.registerTask('default', ['coffee', 'simplemocha']);

	grunt.registerTask('test', ['simplemocha']);
};