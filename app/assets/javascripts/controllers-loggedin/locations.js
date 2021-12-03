APP.controllers_loggedin.locations = (function() {

    function init() {
        if ($("section.location-form").exists()) initLocationForm();
    }

    function initLocationForm() {
      APP.components.formValidation.init();
      APP.components.districtGraetzlInput();
      APP.components.addressInput();

      // User should not be able to change Category if "Spirit & Soul"
      var category = $('#location-cat select').find(":selected").text();
      if (typeof category !== "undefined" && category.indexOf("Spirit") >= 0) {
        $('#location-cat').hide();
      }

      $("#location_description, #location_contact_attributes_hours").autogrow({
          onInitialize: true
      });

      $('#location_product_list').tagsInput({
          'defaultText':'Schlagworte / Tags'
      });

      // online meeting switch
      $('.using-address-switch').on('change', function() {
        var noAddress = $(this).val() == "true";
        $('#not-using-address-fields').toggle(noAddress);
        $('#using-address-fields').toggle(!noAddress);
        $("#using-address-fields").find("input, select").attr("disabled", noAddress);
      });
      $('.using-address-switch:checked').trigger('change');
    }

    return {
      init: init
    };

})();
