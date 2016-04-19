gulp       = require 'gulp'
plumber    = require 'gulp-plumber'
coffee     = require 'gulp-coffee'
sass       = require 'gulp-sass'
notify     = require 'gulp-notify'
sourcemaps = require 'gulp-sourcemaps'


coffeePipeline = (src, dest) ->
    ->
        gulp.src src
            .pipe sourcemaps.init()
            .pipe plumber(errorHandler: notify.onError '<%= error.message %>')
            .pipe coffee { bare:false }
            .pipe sourcemaps.write()
            .pipe gulp.dest dest

gulp.task 'coffee',      coffeePipeline(['./src/**/*.coffee'], './src')
gulp.task 'coffee-spec', coffeePipeline(['./spec/spec/**/*.coffee'], './spec/spec')

gulp.task 'sass', ->
    gulp.src ['./src/**/*.scss']
        .pipe plumber(errorHandler: notify.onError '<%= error.message %>')
        .pipe sass()
        .pipe gulp.dest './src'

gulp.task 'default', ['coffee','coffee-spec', 'sass']
