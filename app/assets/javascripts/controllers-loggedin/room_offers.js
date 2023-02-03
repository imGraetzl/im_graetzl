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
    APP.components.formHelper.formatIBAN();

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
      APP.components.formHelper.maxCategories($(this).parents(".cb-columns"), 5); // init on Change
    }).trigger('change');

  }

  return {
    init: init
  }

})();
