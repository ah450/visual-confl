var gulp = require('gulp');
var fs = require('fs');
var gzip = require('gulp-gzip');
var merge = require('merge2');
var concat = require('gulp-concat');
var minimist = require('minimist');
var uglify = require("gulp-uglify");
var ngAnnotate = require('gulp-ng-annotate');
var minifyHtml = require('gulp-minify-html');
var connect = require('gulp-connect');
var modRewrite = require('connect-modrewrite');
var bower = require('gulp-bower');
var mainBowerFiles = require('main-bower-files');
var css = require('./gulp-tasks/css');
var assets = require('./gulp-tasks/assets');
var templates = require('./gulp-tasks/templates');
var scripts = require('./gulp-tasks/scripts');
var rimraf = require('rimraf');
var watch = require('gulp-watch');

gulp.task('bower-install', function() {
  // Runs bower install
  return bower()
    .pipe(gulp.dest('./bower_components'));
});

gulp.task('bower', ['bower-install', 'create-dirs'], function() {
  // moves main files to lib folder
  return gulp.src(mainBowerFiles(), {base: 'bower_components'})
    .pipe(gulp.dest('libs'));
});

gulp.task('create-dirs', function() {
  var dirs = ['build', 'dist', 'libs'];
  rimraf.sync('libs');
  dirs.forEach(function(dir) {
    try {
      fs.mkdirSync(dir);
    } catch(e) {
      if (e.code != 'EEXIST') {
        throw e;
      }
    }
  });
});



gulp.task('default', ['build']);

gulp.task('build', ['create-dirs', 'bower'], function() {
    var cssStream = css.processSass();
    var scriptStream = scripts.processScripts();
    var dependenciesStream = scripts.processDeps();
    var routesStream = scripts.processRoutes();
    var templatesStream = templates.processTemplates();
    var index = gulp.src('src/index.html');
    var assetsStream = assets.processAssets();
    var js = merge(dependenciesStream, templatesStream, scriptStream, routesStream)
      .pipe(concat('app.js'));
    var streams = merge([cssStream, js, assetsStream, index]);
    return streams.pipe(gulp.dest('build'))
});

var options = minimist(process.argv.slice(2), {
  string: 'dest',
  default: {dest: 'dist'}
})

gulp.task('production-helper', ['create-dirs', 'bower'], function() {
  var cssStream = css.minifyCss(css.processSass());
  var scriptStream = scripts.processScripts().pipe(ngAnnotate()).pipe(uglify());
  var dependenciesStream = scripts.processDeps().pipe(uglify());
  var routesStream = scripts.processRoutes().pipe(uglify({mangle: false}));
  var templatesStream = templates.minifyTemplates();
  var assetsStream = assets.processAssets();
  var index = gulp.src('src/index.html').pipe(minifyHtml({
      empty: true
    }));
  var js = merge(dependenciesStream, templatesStream, scriptStream, routesStream)
    .pipe(concat('app.js'));
  var streams = merge([cssStream, js, assetsStream, index]);
  return streams
    .pipe(gulp.dest(options.dest));
});

gulp.task('production', ['production-helper'], function () {
  var src = [options.dest, '**', '*.{html,css,js,eot,svg,ttf,otf}'].join('/');
  return gulp.src(src)
    .pipe(gzip({ gzipOptions: { level: 9 } }))
    .pipe(gulp.dest(options.dest));
});


gulp.task('server', ['build'], function() {
  connect.server({
    livereload: true,
    root: 'build',
    port: 8000,
    middleware: function() {
      return [
        modRewrite([
          '^/api/(.*)$ http://localhost:3000/api/$1 [P]'
        ])
      ];
    }
  });
});

gulp.task('reload', ['build'], function() {
  return gulp.src('./build/**/*')
    .pipe(connect.reload());
});

gulp.task('dev', ['watch', 'server']);

gulp.task('watch', function() {
  watch(['./src/**', './images/**', 'bower.json'], function() {
    gulp.start('reload');
  });
});
