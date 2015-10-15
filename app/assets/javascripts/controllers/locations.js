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
            $(this).closest('div.form-block').hide();
            event.preventDefault();
        });

        // TODO: change name of wrapper class
        $('section.location-form').on('click', '.add_graetzl_fields', function(event) {
            var fields = $(this).data('fields');
            $('input#location_graetzl_id').replaceWith(fields);
            $(this).hide();
            APP.components.graetzlSelect();
            event.preventDefault();
        });





        if($("section.locations-overview").exists()) {
            initLocationOverview();
        }

        if($("section.location-form").exists()) {
            initLocationForm();
        }


    }

    function initLocationForm() {
        $("#location_description").autogrow();
    }

    function initLocationOverview() {
        var map =  APP.components.graetzlMap;
        var mapdata = jQuery('.locations-overview').data('mapdata');
        map.init(function() {
                map.showMapGraetzl(mapdata.graetzls, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );
    }

// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();