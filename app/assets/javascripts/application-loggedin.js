//= require jquery.tagsinput
//= require jquery.easy-autocomplete
//= require uppy
//= require_directory ./components-loggedin
//= require_directory ./controllers-loggedin

$(document).on('ready', function(event) {

    APP.components.search.init();
    APP.components.fileUpload.init();

});
