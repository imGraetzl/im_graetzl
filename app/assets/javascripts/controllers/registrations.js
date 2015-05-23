APP.controllers.registrations = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.imgUploadPreview();
        APP.components.addressSearchAutocomplete();

        $('#user_birthday').mask('00/00/0000');

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();