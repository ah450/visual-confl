var gulp = require('gulp');
var peg = require('gulp-peg');
var gutil = require('gulp-util');



exports.processGrammar = function() {
  return gulp.src('src/grammar/chr.pegjs')
  .pipe(peg({
    optimize: 'speed',
    allowedStartRules: ['program', 'input'],
    exportVar: 'PEGParser'
  }).on('error', gutil.log))
}