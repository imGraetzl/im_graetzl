// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require underscore
//= require jquery
//= require jquery.turbolinks
//= require jquery.mask
//= require picker
//= require picker.date
//= require picker.time
//= require picker.de_DE
//= require leaflet
//= require enquire
//= require jquery.sumoselect
//= require typeahead.bundle
//= require jquery.noty.packaged
//= require jquery_ujs
//= require jquery.remotipart
//= require turbolinks
//= require modernizr.custom
//= require fastclick
//= require autogrow
//= require refile
//= require_directory ./utils
//= require_directory ./components
//= require_directory ./controllers

$( document ).ready(function() {
  APP.init();
});