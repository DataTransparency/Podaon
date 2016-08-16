/*jshint node: true */
var pkg2 = require('./package.json');

var shell ={
  stage:{
    command: "rm -R stage; mkdir stage; mkdir stage/icons; mkdir stage/splash;",
options:{
      stdout: true,
      stderr: true,
      failOnError: false
    }
  },
  icons2asset:{
    command:"cp stage/icons/*.png ClassfitteriOS/Assets.xcassets/AppIcon.appiconset/"
  }
};

var artworkFolder = __dirname + '/../ClassfitterArtwork/';
var destinationFolder = __dirname + '/stage/';

var tasks = [];
var images = [
['icon.svg', 29, 29, 'icons/Icon29.png'],
['icon.svg', 40, 40, 'icons/Icon40.png'],
['icon.svg', 58, 58, 'icons/Icon58.png'],
['icon.svg', 76, 76, 'icons/Icon76.png'],
['icon.svg', 80, 80, 'icons/Icon80.png'],
['icon.svg', 87, 87, 'icons/Icon87.png'],
['icon.svg', 120, 120, 'icons/Icon120.png'],
['icon.svg', 152, 152, 'icons/Icon152.png'],
['icon.svg', 167, 167, 'icons/Icon167.png'],
['icon.svg', 180, 180, 'icons/Icon180.png'],
['splashShort.svg', 320, 480, 'splash/Default~iphone.png'],
['splashShort.svg', 640, 960, 'splash/Default@2x~iphone.png'],
['splash.svg', 640, 1136, 'splash/Default-568h@2x~iphone.png'],
['splashiPad.svg', 768, 1004, 'splash/Default-Portrait~ipad.png'],
['splashiPad.svg', 1536, 2008, 'splash/Default-Portrait@2x~ipad.png'],
['splashiPadIOS7.svg', 768, 1024, 'splash/Default-Portrait-IOS7~ipad.png'],
['splashiPadIOS7.svg', 1536, 2048, 'splash/Default-Portrait-IOS7@2x~ipad.png'],
['splashiPadLandscape.svg', 1024, 748, 'splash/Default-Landscape~ipad.png'],
['splashiPadLandscape.svg',2048, 1496, 'splash/Default-Landscape@2x~ipad.png'],
['splashiPadLandscapeiOS7.svg', 1024, 768, 'splash/Default-Landscape-iOS7~ipad.png'],
['splashiPadLandscapeiOS7.svg',2048, 1536, 'splash/Default-Landscape-iOS7@2x~ipad.png']
];

var i = 0;
images.map(function(sizes){
  "use strict";
  var sizeY = sizes[2].toString();
  var sizeX = sizes[1].toString();
  var dest = sizes[3].toString();
  var name = sizeX + 'x' + sizeY;
  var src = sizes[0].toString();
  var command = '/Applications/Inkscape.app/Contents/Resources/bin/inkscape --export-png ' + destinationFolder + dest + ' -w ' + sizeX + ' -h '+ sizeY + ' ' + artworkFolder + src;
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
          { width : 167, name : 'Icon167.png' },
          { width : 180, name : 'Icon180.png' }
        ]
      },
      files: [
        {
          expand: true,
          cwd: '../classfitterartwork/',
          src: ['icon.svg'],
          dest : '../../ClassfitteriOS/Assets.xcassets/AppIcon.appiconset'
        }
      ]
    }
  }
  });



  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);


  grunt.registerTask('icons', tasks);
  grunt.registerTask('default', ['shell:stage', 'icons', 'shell:icons2asset']);
  
};