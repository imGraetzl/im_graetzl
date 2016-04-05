APP.controllers.locations = (function() {

    function init() {
        if($("section.selectGraetzl").exists()) initSelectGraetzl();
        if($("section.location-form").exists()) initLocationForm();
        if($("section.masonryFilterGrid").exists()) initLocationOverview();
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

        $('#location_product_list').tagsInput({
            'defaultText':'Tags'
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
        var map =  APP.components.graetzlMap;
        var filter = APP.components.masonryFilterGrid;
        var mapdata = $('#graetzlMapWidget').data('mapdata');

        filter.init();
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


    function initLocationPage() {
        $('.introtxt .txt').linkify({ target: "_blank"});
        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');


        enquire
            //mobile mode
            .register("screen and (max-width:" + APP.config.majorBreakpoints.large + "px)", {
                match : function() {
                    $('.stream').insertAfter('.sideBar');
                }
            })
            //desktop mode
            .register("screen and (min-width:" + APP.config.majorBreakpoints.large + "px)", {
                match : function() {
                    $('.stream').appendTo('.mainContent');
                }
            });


    }




// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
