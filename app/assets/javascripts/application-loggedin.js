//= require jquery.tagsinput
//= require jquery.easy-autocomplete
//= require uppy
//= require_directory ./components-loggedin
//= require_directory ./controllers-loggedin

console.log('application loggedin');

$(document).on('ready', function(event) {

    console.log('application loggedin - on ready');

    var pageToInit = $("body").attr("data-controller");
    APP.controllers_loggedin[pageToInit] && APP.controllers_loggedin[pageToInit].init();

    APP.components.search.init();
    APP.components.fileUpload.init();

});
