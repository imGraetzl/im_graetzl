//= require jquery.tagsinput
//= require jquery.easy-autocomplete
//= require uppy
//= require_directory ./components-loggedin
//= require_directory ./controllers-loggedin

console.log('application loggedin');


document.addEventListener('DOMContentLoaded', function() {
  console.log('application loggedin - DOMContentLoaded');

  var pageToInit = $("body").attr("data-controller");
  APP.controllers_loggedin[pageToInit] && APP.controllers_loggedin[pageToInit].init();
  APP.components.search.init();
  APP.components.fileUpload.init();
});

$(document).on('ready', function(event) {

  console.log('application loggedin - onready');

});
