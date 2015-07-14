APP.controllers.locations = (function() {

    function init() {

        APP.components.addressSearchAutocomplete();
        APP.components.imgUploadPreview();

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();