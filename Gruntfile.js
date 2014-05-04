module.exports = function(grunt) {

	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),

		folders: {
			bin: 'bin',
			src: 'src',
			test: 'test'
		},

		clean: ['<%= folders.bin %>'],

		coffee: {
			compile: {
				expand: true,
				flatten: true,
				cwd: '<%= folders.src %>',
				src: ['*.coffee'],
				dest: '<%= folders.bin %>',
				ext: '.js'
			}
		},

		shell: {
			scrape: {
				command: './node_modules/.bin/coffee scraper/scraper.coffee'
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

			all: { src: ['<%= folders.test %>/**/*.coffee'] }
		}
	});

	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-simple-mocha');
	grunt.loadNpmTasks('grunt-shell');

	// Default task(s).
	grunt.registerTask('default', ['coffee', 'simplemocha']);

	grunt.registerTask('scrape', ['shell:scrape']);

	grunt.registerTask('test', ['simplemocha']);
};