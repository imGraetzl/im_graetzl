APP.controllers.locations = (function() {

    function init() {
        if($("section.selectGraetzl").exists()) initSelectGraetzl();
        if($("section.location-form").exists()) initLocationForm();
        if($("section.locations-overview").exists()) initLocationOverview();
        if($("section.locationPage").exists()) initLocationPage();
    }



    function initSelectGraetzl() {
        APP.components.graetzlSelect();
    }

    function initLocationForm() {
        $("#location_description, #location_contact_attributes_hours").autogrow({
            onInitialize: true
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
    }


    function initLocationOverview() {
        var numBoxes = $(".cardBoxCollection .cardBox").length;
        var map =  APP.components.graetzlMap;
        var mapdata = jQuery('#graetzlMapWidget').data('mapdata');

        map.init(function() {
                map.showMapGraetzl(mapdata.graetzls, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );

        if (numBoxes > 0) $(".cardBox:nth-child(3)").after($(".cardbox-wrp"));
    }


    function initLocationPage() {
        APP.components.tabs.initTabs(".tabs-ctrl");
        $('.introtxt .txt').linkify({
            target: "_blank"
        });
    }




// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
