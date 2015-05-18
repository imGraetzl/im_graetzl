APP.controllers.meetings = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();
        APP.components.imgUploadPreview();


        $('.datepicker').pickadate({
            formatSubmit: 'yyyy-mm-dd',
            hiddenSuffix: ''
        });

        $('.timepicker').pickatime({
            interval: 15,
            format: 'HH:i',
            formatSubmit: 'HH:i',
            hiddenSuffix: ''
        });

        $('select.categories').SumoSelect({
            placeholder: 'Kategorien wählen',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

        // titleImg
        $(document).on('ready page:load', function() {
            $(".titleImg").css("opacity", 1);
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();