var grunt=require("grunt");
var grunt=require("grunt");

grunt.initConfig({
  rasterize : {
    ios : {
      options: {
        sizes : [
          { width : 29, name : 'Icon-Small.png' },
          { width : 40, name : 'Icon-Small-40.png' },
          { width : 58, name : 'Icon-Small@2x.png' },
          { width : 76, name : 'Icon-76.png' },
          { width : 80, name : 'Icon-Small-40@2x.png' },
          { width : 87, name : 'Icon-Small@3x.png' },
          { width : 120, name : 'Icon-Small-40@3x.png' },
          { width : 120, name : 'Icon-60@2x.png' },
          { width : 152, name : 'Icon-76@2x.png' },
          { width : 180, name : 'Icon-60@3x.png' },
          { width : 512, name : 'iTunes@512.png' },
          { width : 1024, name : 'iTunes@1024.png' }
        ]
      },
      files: [
        {
          expand: true,
          cwd: 'src',
          src: ['**/*.svg'],
          dest : '/bin'
        }
      ]
    }
  }
 
});

grunt.loadNpmTasks('grunt-phantom-rasterize');
require('matchdep').filter('grunt-*').forEach(grunt.loadNpmTasks);
grunt.registerTask('default', ['rasterize']);