APP.controllers.meetings = (function() {

    function init() {

        APP.components.addressSearchAutocomplete();

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

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();