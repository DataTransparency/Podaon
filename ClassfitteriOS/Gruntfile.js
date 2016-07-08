/*jshint node: true */
var pkg2 = require('./package.json');

var shell ={
  stage:{
    command: "rm -R stage; mkdir stage;",
options:{
      stdout: true,
      stderr: true,
      failOnError: false
    }
  },
  iosCreateIconsDirectory:{
    command: "rm -R Resources/Icons/; mkdir Resources/Icons/; rm -R Resources/Splash/; mkdir Resources/Splash/",
    options:{
      stdout: true,
      stderr: true,
      failOnError: true
    }
  }
};
var artworkStage = '../node_modules/classfitterartwork/';
var destination = 'ClassfitteriOS/Resources/';

var tasks = [];
var images = [
[artworkStage + 'splashShort.svg', 320, 480, destination + '/splash/Default~iphone.png'],
[artworkStage + 'splashShort.svg', 640, 960, destination + '/splash/Default@2x~iphone.png'],
[artworkStage + 'splash.svg', 640, 1136, destination + '/splash/Default-568h@2x~iphone.png'],
[artworkStage + 'splashiPad.svg', 768, 1004, destination + '/splash/Default-Portrait~ipad.png'],
[artworkStage + 'splashiPad.svg', 1536, 2008, destination + '/splash/Default-Portrait@2x~ipad.png'],
[artworkStage + 'splashiPadIOS7.svg', 768, 1024, destination + '/splash/Default-Portrait-IOS7~ipad.png'],
[artworkStage + 'splashiPadIOS7.svg', 1536, 2048, destination + '/splash/Default-Portrait-IOS7@2x~ipad.png'],
[artworkStage + 'splashiPadLandscape.svg', 1024, 748, destination + '/splash/Default-Landscape~ipad.png'],
[artworkStage + 'splashiPadLandscape.svg',2048, 1496, destination + '/splash/Default-Landscape@2x~ipad.png'],
[artworkStage + 'splashiPadLandscapeiOS7.svg', 1024, 768, destination + '/splash/Default-Landscape-iOS7~ipad.png'],
[artworkStage + 'splashiPadLandscapeiOS7.svg',2048, 1536, destination + '/splash/Default-Landscape-iOS7@2x~ipad.png'],
];

var i = 0;
images.map(function(sizes){
  "use strict";
  var sizeY = sizes[2].toString();
  var sizeX = sizes[1].toString();
  var dest = sizes[3].toString();
  var name = sizeX + 'x' + sizeY;
  var src = sizes[0].toString();
  var command = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png ' + dest + ' -w ' + sizeX + ' -h '+ sizeY + ' ' + src;
  shell['s' + i.toString()] = {
    command: command,
    options:{
      failOnError: true
    }
  };
  tasks.push('shell:s' + i.toString());
  i++;
});



module.exports = function(grunt) {
  "use strict";
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    bumpup: {
        options: {
            updateProps: {
                pkg: 'package.json'
            }
        },
        file: 'package.json'
    },
    shell: shell,
    watch: {
      local: {
        options: {
          debounceDelay: 5000,
          interrupt: true
        },
        files: ['*.js','src/**/*.js', 'test/**/*.js'],
        tasks: ['default']
      }
    },
    rasterize : {
    ios : {
      options: {
        sizes : [
          { width : 29, name : 'Icon29.png' },
          { width : 40, name : 'Icon40.png' },
          { width : 58, name : 'Icon58.png' },
          { width : 76, name : 'Icon76.png' },
          { width : 80, name : 'Icon80.png' },
          { width : 87, name : 'Icon87.png' },
          { width : 120, name : 'Icon120.png' },
          { width : 152, name : 'Icon152.png' },
          { width : 180, name : 'Icon180.png' }
        ]
      },
      files: [
        {
          expand: true,
          cwd: 'node_modules/classfitterartwork/',
          src: ['icon.svg'],
          dest : '../../ClassfitteriOS/Assets.xcassets/AppIcon.appiconset'
        }
      ]
    }
  }
  });


//{ width : 50, name : 'Icon50.png' },
//{ width : 72, name : 'Icon72.png' },
//          { width : 100, name : 'Icon100.png' },
//          { width : 114, name : 'Icon114.png' },
//          { width : 144, name : 'icon144.png' },
//          { width : 512, name : 'Icon512.png' },
//         { width : 1024, name : 'Icon1024.png' }



  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);


  grunt.registerTask('icons', tasks);
  grunt.registerTask('build', ['shell:stage', 'shell:iosCreateIconsDirectory', 'icons','shell:ios']);

  grunt.registerTask('development', ['build', 'shell:iosRelease']);
  grunt.registerTask('production', ['build', 'shell:iosRelease']);
  grunt.registerTask('test', []);
  grunt.registerTask('publish', ['bumpup:patch', 'shell:publish']);



};