var gulp = require('gulp');

function processAssets() {
  return gulp.src('images/**/*', {base: '.'});
}


exports.processAssets = processAssets;