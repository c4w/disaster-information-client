gulp       = require 'gulp'
plumber    = require 'gulp-plumber'
coffee     = require 'gulp-coffee'
sass       = require 'gulp-sass'
notify     = require 'gulp-notify'
sourcemaps = require 'gulp-sourcemaps'
webserver  = require 'gulp-webserver'
_          = require 'underscore'

class IOs
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


ios = new IOs [
    {
        name: 'app'
        src: ['./src/**/*.coffee']
        dest: './src'
    },{
        name: 'spec'
        src: ['./spec/spec/**/*.coffee']
        dest: './spec/spec'
    },{
        name: 'sass'
        src: ['./src/**/*.scss']
        dest: './src'
    },{
        name: 'built'
        src: ['./src']
    }
]

coffeePipeline = (src, dest) ->
    ->
        gulp.src src
            .pipe sourcemaps.init()
            .pipe plumber(errorHandler: notify.onError '<%= error.message %>')
            .pipe coffee { bare:false }
            .pipe sourcemaps.write()
            .pipe gulp.dest dest

gulp.task 'coffee-app', coffeePipeline.apply(null, ios.of 'app')

gulp.task 'coffee-spec', coffeePipeline.apply(null, ios.of 'spec')

gulp.task 'sass', ->
    gulp.src(ios.src 'sass')
        .pipe plumber(errorHandler: notify.onError '<%= error.message %>')
        .pipe sass()
        .pipe gulp.dest(ios.dest 'sass')

gulp.task 'build', ['coffee-app','coffee-spec', 'sass']

gulp.task 'webserver', ->
    gulp.src('./')
        .pipe webserver {livereload: true}

gulp.task 'default', ['build']

gulp.task 'dev', ['build','webserver'], ->
    gulp.watch ios.src(), ['build']
