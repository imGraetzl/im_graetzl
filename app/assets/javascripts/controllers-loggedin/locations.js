APP.controllers_loggedin.locations = (function() {

    function init() {
        if ($("section.location-form").exists()) initLocationForm();
        if ($("section.location-page").exists()) initStreamForm();
    }

    function initStreamForm() {
      $('.stream-switch').on('change', function() {
        var showMenuFields = $(this).val() == "menu";
        if (showMenuFields) {
          $('#location-menu-form').removeClass("hidden");
          $('#location-post-form').addClass("hidden");
        } else {
          $('#location-menu-form').addClass("hidden");
          $('#location-post-form').removeClass("hidden");
        }
      });
      $('.datepicker').pickadate({
        formatSubmit: 'yyyy-mm-dd',
        format: 'dddd, dd mmm, yyyy',
        hiddenName: true,
        //min: true
      });
    }

    function initLocationForm() {
      APP.components.formValidation.init();
      APP.components.districtGraetzlInput();
      APP.components.addressInput();
      APP.components.formHelper.maxChars();
      APP.components.formHelper.savingBtn();

      // User should not be able to change Category if "Spirit & Soul"
      var category = $('#location-cat select').find(":selected").text();
      if (typeof category !== "undefined" && category.indexOf("Spirit") >= 0) {
        $('#location-cat').hide();
      }

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
      init: init,
      initStreamForm: initStreamForm
    };

})();
