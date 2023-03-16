APP.controllers_loggedin.room_offers = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
  }

  function initRoomForm() {
    APP.components.tabs.initTabs(".tabs-ctrl");
    APP.components.addressInput();
    APP.components.formValidation.init();
    APP.components.search.userAutocomplete();
    APP.components.formHelper.savingBtn();

    // Init Tab for Saving Single Tabs
    var initTab = APP.controllers.application.getUrlVars()["initTab"];
    if (typeof initTab !== "undefined") {
      APP.components.tabs.openTab(initTab);
    }

    $(".next-screen, .prev-screen").on("click", function() {
      $('.tabs-ctrl').trigger('show', '#' + $(this).data("tab"));
      $('.tabs-ctrl').get(0).scrollIntoView();
    });

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

    var initAvailabilitySelect = function() {
      $(".availability-select").on("change", function() {
        var day = $(this).data("weekday");
        if ($(this).val() == "0") {
          $(".availability-input-" + day).prop("disabled", true).closest('.input-select').addClass('disabled');
        } else {
          $(".availability-input-" + day).prop("disabled", false).closest('.input-select').removeClass('disabled');
        }
      }).change();

      $(".hour-from").on("change", function() {
        var $to_field = $('.hour-to#' + $(this).attr('id').replace("_from","_to"));
        var hour = $(this).val();
        $to_field.find("option").not(':empty').each(function(i, o) {
          $(o).attr("disabled", $(o).val() * 1 <= hour * 1)
        });
      });

    }

    // Slot Fields Toogle
    var slotsSection = null;
    $('.slot-radios .rental-toggle-input').on('change', function() {
      var rentalEnabled = $('.slot-radios .rental-toggle-input:checked').val() == 'true';
      if (rentalEnabled && slotsSection) {
        $('#slot-fields').replaceWith(slotsSection);
        $('#slot-fields').hide().slideDown();
        slotsSection = null;
        APP.components.formHelper.formatIBAN();
        initAvailabilitySelect();
      } else if (!rentalEnabled && !slotsSection){
        slotsSection = $('#slot-fields').clone();
        $('#slot-fields').empty();
        initAvailabilitySelect();
      } else {
        APP.components.formHelper.formatIBAN();
        initAvailabilitySelect();
      }

    }).change();

    $(".room-categories input").on("change", function() {
      APP.components.formHelper.maxCategories($(this).parents(".cb-columns"), 5); // init on Change
    }).trigger('change');

  }

  return {
    init: init
  }

})();
