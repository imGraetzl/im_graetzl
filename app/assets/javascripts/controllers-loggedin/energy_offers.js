APP.controllers_loggedin.energy_offers = (function() {

  function init() {
    if ($("section.energy-offer-form").exists()) initEnergyForm();
  }

  function initEnergyForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    APP.components.formHelper.savingBtn();

    // show eeg sub_types
    $('input[name="energy_offer[energy_type]"]').on("change", function() {

      show_beg(true);

      if ($(this).is(':checked') && ["eeg"].includes($(this).val())) {
        $(".eeg-types").show();
        $("#energy_offer_energy_type_eeg").prop('checked', false).addClass("checked");
        $("#energy_offer_energy_type_eeg_local").prop('checked', true);
      } else if ($(this).is(':checked') && ["eeg_local", "eeg_regional"].includes($(this).val())) {
        $(".eeg-types").show();
        $("#energy_offer_energy_type_eeg").prop('checked', false).addClass("checked");
      } else if ($(this).is(':checked') && ["beg"].includes($(this).val())) {
        $(".eeg-types").hide();
        $("#energy_offer_energy_type_eeg").prop('checked', false).removeClass("checked");
        show_beg(false);
      } else if ($(this).is(':checked') && [ "unclear"].includes($(this).val())) {
        $(".eeg-types").hide();
        $("#energy_offer_energy_type_eeg").prop('checked', false).removeClass("checked");
      }
    }).change();

    function show_beg(show) {
      if (show) {
        $(".beg").show();
      } else {
        $(".beg").hide();
        $(".beg input:checkbox").prop('checked', false);
      }
    }

    // show category sub_types
    $('input[name="energy_offer[energy_category_ids][]"]').on("change", function() {
      if ($(this).is(':checked')) {
        $(`.sub_type_${$(this).val()}`).show();
      } else {
        $(`.sub_type_${$(this).val()} input:checkbox`).prop('checked', false);
        $(`.sub_type_${$(this).val()}`).hide();
      }
    }).change();

  }

  return {
    init: init
  }

})();
