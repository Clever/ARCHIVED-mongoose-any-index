module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffeelint:
      lib:
        src: ['lib/**/*.coffee']

    coffee:
      options:
        sourceMap: true
      lib:
        files: [
          expand: true,
          cwd: 'lib',
          src: ['**/*.coffee'],
          dest: 'lib-js',
          ext: '.js'
        ]

    env:
      test:
        NODE_ENV: 'test'
        DEBUG: 'mongoose-any-index:*'

    simplemocha:
      options:
        timeout: 60000
        ignoreLeaks: false
      all:
        src: 'test/**/*.coffee'

    regarde:
      coffee:
        files: 'lib/**/*.coffee'
        tasks: ['coffeelint', 'coffee']

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-regarde'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-env'

  grunt.registerTask 'test', ['default', 'env:test', 'simplemocha']
  grunt.registerTask 'default', ['coffeelint', 'coffee']
  grunt.registerTask 'watch', ['default', 'regarde']
