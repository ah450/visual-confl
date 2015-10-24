var gulp = require('gulp');
var peg = require('gulp-peg');
var gutil = require('gulp-util');



exports.processGrammar = function() {
  return gulp.src('src/grammar/chr.pegjs')
  .pipe(peg({
    optimize: 'speed',
    exportVar: 'PEGParser'
  }).on('error', gutil.log))
}