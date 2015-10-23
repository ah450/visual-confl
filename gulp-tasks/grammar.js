var gulp = require('gulp');



exports.processGrammar = function() {
  return gulp.src('src/**/*.pegjs');
}