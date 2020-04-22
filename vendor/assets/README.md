# Leaflet
 
Since there is no 'official' convention for naming Leaflet plugins I'd like to start a convention of storing the unzipped downloaded release folder under 'vendor' and copying the necessary files to their appropriate locations under 'vendor/assets'.  This way the next developer will know what version of the plugin is being used as well as what files belong to which plugin.

# Able Player

## _Able Player_ has the following third party dependencies:

* _Able Player_ uses jQuery. Version 3.2.1 or higher is recommended. The example code below uses Google’s hosted libraries; no download required.
* _Able Player_ uses js-cookie to store and retrieve user preferences in cookies. This script is distributed with _Able Player_. Prior to version 2.3, Able Player used jquery.cookie for this same purpose.

To install Able Player, copy the following files from the Able Player repo into a folder on your web server:

* build/*
* button-icons/*
* images/*
* styles/* (optional, see note below)
* thirdparty/* (includes js-cookie, as mentioned above)
* translations/*
* LICENSE

The _build_ folder includes minified production code (_ableplayer.min.js_ and _ableplayer.min.css_). For debugging and/or style customization purposes, human-readable source files are also available:

* build/ableplayer.js
* styles/ableplayer.css

## Heliotrope asset pipeline configuration:

* fulcrum/
    * assets/
        * button-icons/*
        * translations/*
* vendor/
    * ableplayer-v4.3-66-g7fbf2c7 (original files as described above)
    * assets/
        * images/*
        * javascripts/
            * ableplayer.js (modified ableplayer.js)
            * ableplayer_embed.js (modified modified ableplayer.js)
        * stylesheets
            * ableplayer.css

NOTE: **ableplayer.js** has been modified to change hard coded relative paths to work in the above pipeline configuration. Do a file compare with the original file to locate all the modifications.

NOTE: **ableplayer_embed.js** has additional modification to be embedded into EPUBs. Do a file compare with the original file to locate all the modifications.

NOTE: **ableplayer.css** has been modified to play nice with bootstrap-sprockets.  Do a file compare with the original file to locate all the modifications.  See also ableplayer-bootstrap-sprockets.css
