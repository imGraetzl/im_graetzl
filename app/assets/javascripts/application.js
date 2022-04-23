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
//= require jquery3
//= require jquery_ujs
//= require jquery.detect_swipe
//= require jquery.ihavecookies
//= require picker
//= require jquery.tabslet.min
//= require picker.date
//= require picker.time
//= require picker.de_DE
//= require enquire
//= require jquery.sumoselect
//= require jquery.dropdown
//= require masonry.pkgd.min
//= require linkify-jquery.min
//= require jquery.remotipart
//= require lightslider
//= require modernizr.custom
//= require autoheight
//= require jBox.min
//= require cocoon
//= require_directory ./utils
//= require_directory ./components
//= require_directory ./controllers

document.addEventListener('DOMContentLoaded', function() {
  APP.init();
});
