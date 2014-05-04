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
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');

	// Default task(s).
	grunt.registerTask('default', ['coffee']);
};