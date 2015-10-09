APP.controllers.registrations = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();
        APP.components.graetzlSelect();
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();