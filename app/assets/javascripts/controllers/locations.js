APP.controllers.locations = (function() {

    function init() {
        if($("section.selectGraetzl").exists()) initSelectGraetzl();
        if($("section.location-form").exists()) initLocationForm();
        if($("section.location-page").exists()) initLocationPage();
    }


    function initSelectGraetzl() {
      APP.components.graetzlSelect();
    }

    function initLocationForm() {

        APP.components.formValidation.init();
        APP.components.addressSearchAutocomplete();

        $("#location_description, #location_contact_attributes_hours").autogrow({
            onInitialize: true
        });

        $('form').on('click', '.add_address_fields', function(event) {
            var fields = $(this).data('fields');
            $(this).replaceWith(fields);
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

    function initLocationPage() {

        // Sidebar Button Click
        $('#requestLocationBtn').on('click', function(event){
          event.preventDefault();
          var href = $(this).attr('href');
          gtag(
            'event', 'Location :: Click :: Kontaktieren', {
            'event_category': 'Location',
            'event_callback': function() {
              location.href = href;
            }
          });
        });

        $('.introtxt .txt').linkify({ target: "_blank"});
        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');

        $('.autosubmit-stream').submit();

        // open comments if post hash exists
        var hash = window.location.hash.substr(1);
        if (hash.indexOf("location_post") != -1) {
          $( "#" + hash + " .show-all-comments-link" ).click();
        }

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

    return {
      init: init
    };

})();
