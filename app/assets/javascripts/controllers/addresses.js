APP.controllers.addresses = (function() {

    function init() {
        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();
    }

    return {
        init: init
    }

})();