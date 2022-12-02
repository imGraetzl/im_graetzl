APP.controllers_loggedin.tool_offers = (function() {

    function init() {
      if ($("section.tool-form").exists()) { initToolOfferForm(); }
    }

    function initToolOfferForm() {
      APP.components.tabs.initTabs(".tabs-ctrl");
      APP.components.addressInput();
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

      var subcategoryOptions = $(".subcategory-select option[data-parent-id]").detach();
      $(".category-select").on("change", function() {
        $(".subcategory-select option[data-parent-id]").remove();
        if ($(this).val()) {
          $(".subcategory-select").append(subcategoryOptions.filter("[data-parent-id=" + $(this).val() + "]"));
        }
      }).change();

      // Tag Input JS
      $('#custom-keywords').tagsInput({
        'defaultText':'Kurz in Stichworten ..'
      });

      // Deposit Fields Toogle
      $('.deposit-radios .deposit-toggle-input').on('change', function() {
        var depositEnabled = $('.deposit-radios .deposit-toggle-input:checked').val() == 'true';
        if (depositEnabled) {
          $('#deposit-fields').slideDown();
        } else if (!depositEnabled){
          $('#deposit-fields input').val('');
          $('#deposit-fields').hide();
        }
      }).change();

    }

    return {
      init: init
    };

})();
