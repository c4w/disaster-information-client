gulp       = require 'gulp'
plumber    = require 'gulp-plumber'
coffee     = require 'gulp-coffee'
sass       = require 'gulp-sass'
notify     = require 'gulp-notify'
sourcemaps = require 'gulp-sourcemaps'
webserver  = require 'gulp-webserver'
_          = require 'underscore'

class FileIOs
    constructor: (data) ->
        unless data instanceof Array
            throw new Error 'constructor reqire Array.'
        @data = data

    src: (name) ->
        unless name?
            return _.flatten @data.map (e) -> e.src
        else
            filtered = @data.filter (e) -> e.name is name
            if filtered[0]
                return filtered[0].src
            else
                throw new Error "required io data named `#{name}` lacks `src` property."

    dest: (name) ->
        filtered = @data.filter (e) -> e.name is name
        if filtered[0]
            return filtered[0].dest
        else
            throw new Error "required io data named `#{name}` lacks `dest` property."

    of: (name) ->
        [@src(name), @dest(name)]


fileIOs = new FileIOs [
    {
        name: 'app'
        src: ['./src/**/*.coffee']
        dest: './src'
    },{
        name: 'spec'
        src: ['./spec/spec/**/*.coffee']
        dest: './spec/spec'
    },{
        name: 'gulpfile' # for user who don't have coffee-script -g
        src: ['./gulpfile.coffee']
        dest: './'
    },{
        name: 'sass'
        src: ['./src/**/*.scss']
        dest: './src'
    },{
        name: 'built'
        src: ['./src']
    }
]

{host, port} = {host:'localhost', port:8000}

coffeePipeline = (src, dest) ->
    ->
        gulp.src src
            .pipe sourcemaps.init()
            .pipe plumber(errorHandler: notify.onError '<%= error.message %>')
            .pipe coffee { bare:false }
            .pipe sourcemaps.write()
            .pipe gulp.dest dest

gulp.task 'coffee-app', coffeePipeline.apply(null, fileIOs.of 'app')

gulp.task 'coffee-spec', coffeePipeline.apply(null, fileIOs.of 'spec')

gulp.task 'coffee-gulpfile', coffeePipeline.apply(null, fileIOs.of 'gulpfile')

gulp.task 'sass', ->
    gulp.src(fileIOs.src 'sass')
        .pipe plumber(errorHandler: notify.onError '<%= error.message %>')
        .pipe sass()
        .pipe gulp.dest(fileIOs.dest 'sass')

gulp.task 'build', ['coffee-app','coffee-spec', 'coffee-gulpfile', 'sass']

gulp.task 'webserver', ->
    gulp.src('./')
        .pipe webserver {
            host
            port
            livereload: true
        }

gulp.task 'notice', ->
    console.log 'If you fix gulpfile.coffee, please reload gulp.'

gulp.task 'default', ['build']

gulp.task 'dev', ['notice', 'build','webserver'], ->
    gulp.watch fileIOs.src(), ['build']
