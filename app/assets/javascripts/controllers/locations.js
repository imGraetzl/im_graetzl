APP.controllers.locations = (function() {

    function init() {
        if ($("section.location-form").exists()) initLocationForm();
        if ($("section.location-page").exists()) initLocationPage();
    }

    function initLocationForm() {
      APP.components.formValidation.init();
      APP.components.graetzlSelect();
      APP.components.addressInput();

      $("#location_description, #location_contact_attributes_hours").autogrow({
          onInitialize: true
      });

      $('#location_product_list').tagsInput({
          'defaultText':'Tags'
      });

      // online meeting switch
      $('.using-address-switch').on('change', function() {
        var showAddress = $(this).val() == "true";
        $('#not-using-address-fields').toggle(!showAddress);
        $('#using-address-fields').toggle(showAddress);
        $("#using-address-fields").find("input, select").attr("disabled", !showAddress);
      });
      $('.using-address-switch:checked').trigger('change');
    }

    function initLocationPage() {

        APP.components.leafletMap.init($('#leafletMap'));

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
