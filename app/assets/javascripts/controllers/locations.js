APP.controllers.locations = (function() {

    function init() {

        APP.components.addressSearchAutocomplete();
        APP.components.graetzlSelect();

        $('select.categories').SumoSelect({
            placeholder: 'Wähle einen oder mehreren Kategorien',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

        $('form').on('click', '.add_address_fields', function(event) {
            var fields = $(this).data('fields');
            $(this).replaceWith(fields);
            event.preventDefault();
        });

        $('form').on('click', '.remove_address_fields', function(event) {
            $(this).prev('input[type=hidden]').val('1');
            $(this).closest('div.user-personal').hide();
            event.preventDefault();
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();