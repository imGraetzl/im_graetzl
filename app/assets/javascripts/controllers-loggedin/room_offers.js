APP.controllers_loggedin.room_offers = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
  }

  function initRoomForm() {
    APP.components.tabs.initTabs(".tabs-ctrl");
    APP.components.addressInput();
    APP.components.formValidation.init();
    APP.components.search.userAutocomplete();
    $("textarea").autogrow({ onInitialize: true });

    $(".next-screen, .prev-screen").on("click", function() {
      $('.tabs-ctrl').trigger('show', '#' + $(this).data("tab"));
      $('.tabs-ctrl').get(0).scrollIntoView();
    });

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

    $(".availability-select").on("change", function() {
      var day = $(this).data("weekday");
      if ($(this).val() == "0") {
        $(".availability-input-" + day).prop("disabled", true);
      } else {
        $(".availability-input-" + day).prop("disabled", false);
      }
    }).change();

    // Slot Fields Toogle
    var slotsSection = null;
    $('.slot-radios .rental-toggle-input').on('change', function() {
      var rentalEnabled = $('.slot-radios .rental-toggle-input:checked').val() == 'true';
      if (rentalEnabled && slotsSection) {
        $('#slot-fields').replaceWith(slotsSection);
        $('#slot-fields').hide().slideDown();
        slotsSection = null;
      } else if (!rentalEnabled && !slotsSection){
        slotsSection = $('#slot-fields').clone();
        $('#slot-fields').empty();
      }
    }).change();


    $(".room-categories input").on("change", function() {
      maxCategories(); // init on Change
    });

    maxCategories(); // init on Load

  }

  function maxCategories() {
    if ($(".room-categories input:checked").length >= 5) {
      $(".room-categories input:not(:checked)").each(function() {
        $(this).prop("disabled", true);
        $(this).parents(".input-checkbox").addClass("disabled");
      });
    } else {
      $(".room-categories input").prop("disabled", false);
      $(".room-categories .input-checkbox").removeClass("disabled");
    }
  }

  return {
    init: init
  }

})();