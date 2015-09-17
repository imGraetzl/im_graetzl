APP.controllers.locations = (function() {

    function init() {

        APP.components.addressSearchAutocomplete();

        $('select.categories').SumoSelect({
            placeholder: 'Wähle einen oder mehreren Kategorien',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();