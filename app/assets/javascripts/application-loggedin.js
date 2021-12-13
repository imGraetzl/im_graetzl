//= require jquery.tagsinput
//= require jquery.easy-autocomplete
//= require uppy
//= require_directory ./components-loggedin
//= require_directory ./controllers-loggedin

$(document).on('ready', function(event) {

    var pageToInit = $("body").attr("data-controller");
    APP.controllers_loggedin[pageToInit] && APP.controllers_loggedin[pageToInit].init();
    
    APP.components.search.init();
    APP.components.fileUpload.init();

});
