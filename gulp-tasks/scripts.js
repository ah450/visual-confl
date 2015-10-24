var gulp = require('gulp');
var concat = require('gulp-concat');
var jshint = require('gulp-jshint');
var coffee = require('gulp-coffee');
var coffeelint = require('gulp-coffeelint');
var stylishCoffee = require('coffeelint-stylish');
var gutil = require('gulp-util');
var order = require('gulp-order');
var merge = require('merge2');

function processScripts() {
  var coffeeScript = gulp.src(['src/**/*.coffee', '!src/routes/**/*', '!src/modernize.coffee'])
    .pipe(coffeelint())
    .pipe(coffeelint.reporter(stylishCoffee))
    .pipe(coffee().on('error', gutil.log));
  var js = gulp.src(['src/**/*.js'])
    .pipe(jshint())
    .pipe(jshint.reporter('jshint-stylish'));
  return merge([coffeeScript, js]);
}

function processRoutes() {
return routes = gulp.src(['src/routes/**/*.coffee'])
    .pipe(coffeelint())
    .pipe(coffeelint.reporter(stylishCoffee))
    .pipe(coffee().on('error', gutil.log));
}

function processDeps() {
  var libs =  gulp.src('libs/**/*.js')
      .pipe(order([
        'libs/jquery/**/*.js',
        'libs/angular/*.js',
        'libs/**/*.js',
        ], { base: './'}));
  return libs;
}

function processSpecs() {
  var coffeeScript = gulp.src(['spec/**/*.coffee'])
    .pipe(coffeelint())
    .pipe(coffeelint.reporter(stylishCoffee))
    .pipe(coffee().on('error', gutil.log));
  var js = gulp.src(['spec/**/*.js'])
    .pipe(jshint())
    .pipe(jshint.reporter('jshint-stylish'));
  return merge([coffeeScript, js]);
}
exports.processScripts = processScripts;
exports.processDeps = processDeps;
exports.processRoutes = processRoutes;
exports.processSpecs = processSpecs;