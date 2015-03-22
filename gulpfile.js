var gulp = require('gulp');
var ngHtml2Js = require("gulp-ng-html2js");
var concat = require('gulp-concat');
var fs = require('fs');
var path = require('path');
var merge = require('merge-stream');
var uglify = require('gulp-uglify');
var ngAnnotate = require('gulp-ng-annotate');
var jshint = require('gulp-jshint');
var stylish = require('jshint-stylish');
var bower = require('gulp-bower');
var mainBowerFiles = require('main-bower-files');
var del = require('del');
var connect = require('gulp-connect');
var watch = require('gulp-watch');
var sass = require('gulp-sass');
var concatCss = require('gulp-concat-css');

function getFolders(dir) {
    return fs.readdirSync(dir)
      .filter(function(file) {
        return fs.statSync(path.join(dir, file)).isDirectory();
      });
}

gulp.task('bower', function(){
    return bower()
        .pipe(gulp.dest('./bower_components'));
});

gulp.task('vendor', ['bower'], function() {
    return gulp.src(mainBowerFiles(), {base: './bower_components'})
        .pipe(gulp.dest('./lib'));
});

gulp.task('html-to-js', function() {
    var options = {
        moduleName: 'vconfl-templates',
        prefix: 'views/'
    };
    return gulp.src('front/views/*.html')
        .pipe(ngHtml2Js(options))
        .pipe(gulp.dest('./build/'));
});

gulp.task('scripts', ['bower'], function() {
    var folders = getFolders('./front');
    var tasks = folders.map(function (folder) {
        return gulp.src(path.join('./front', folder, '/*.js'))
            .pipe(jshint())
            .pipe(jshint.reporter('jshint-stylish'))
            .pipe(concat(folder + '.js'));
    });
    tasks.push(
        gulp.src('./front/*.js')
            .pipe(jshint())
            .pipe(jshint.reporter('jshint-stylish'))
            .pipe(concat('front.js'))
        );
    return merge(tasks)
        .pipe(concat('app.js'))
        .pipe(gulp.dest('./build/'));
});

gulp.task('move-assets', ['vendor'], function() {
    var tasks = [];
    tasks.push(
            gulp.src('./front/index.html')
                .pipe(gulp.dest('./dist'))
                .pipe(gulp.dest('./build'))
        )
    tasks.push(
            gulp.src('./images/*', {base: './'})
                .pipe(gulp.dest('./dist'))
                .pipe(gulp.dest('./build'))
        )
    return merge(tasks);
});


gulp.task('concat-build', ['scripts', 'html-to-js', 'move-assets', 'vendor'], function() {

    return gulp.src([ './lib/*.js', './lib/**/*.js', './build/*.js'])
        .pipe(concat('app.js'))
        .pipe(gulp.dest('./build/'));
});

gulp.task('sass', ['html-to-js'], function() {
    return gulp.src('./front/style/*.scss')
        .pipe(sass())
        .pipe(gulp.dest('./build/css/'));
});

gulp.task('css', ['sass', 'vendor'], function() {
    return gulp.src(['./lib/**/*.css', './build/css/*.css'])
        .pipe(concatCss('main.css'))
        .pipe(gulp.dest('./build/'))
        .pipe(gulp.dest('./dist/'));
});

gulp.task('uglify', ['concat-build'], function() {
    return gulp.src('./build/app.js')
        .pipe(ngAnnotate())
        .pipe(uglify())
        .pipe(gulp.dest('./dist/'));
});




gulp.task('clean', function() {
    del(['./dist', './build', './lib']);
});


gulp.task('webserver', ['concat-build', 'watch', 'css'], function() {
    connect.server({
        livereload: true,
        root: 'build'
    });
});


gulp.task('reload', ['concat-build', 'css'], function() {
    return gulp.src('./build/**/*')
        .pipe(connect.reload());
});

gulp.task('watch', function() {
    watch('./front/**/*', function() {
        gulp.start('reload')
    });
});

gulp.task('dev', ['clean'], function() {
    return gulp.start('webserver');
})

gulp.task('dist', ['clean'], function() {
    return gulp.start('uglify', 'css');
});
