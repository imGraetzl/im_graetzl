APP.controllers.tool_offers = (function() {

    function init() {
      if ($("section.form-new-toolteiler").exists()) { initToolOfferForm(); }
      if ($("section.toolTeiler-detail").exists()) { initToolOfferDetails(); }
    }

    function initToolOfferForm() {
      APP.components.tabs.initTabs(".tabs-ctrl");
      APP.components.addressSearchAutocomplete();

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
          $('#deposit-fields').slideUp();
        }
      }).change();

    }

    function initToolOfferDetails() {

      APP.components.leafletMap.init($('#leafletMap'));

      $('.request-price-form').find(".date-from, .date-to").pickadate({
        hiddenName: true,
        min: true,
        formatSubmit: 'yyyy-mm-dd',
        format: 'ddd, dd mmm, yyyy',
        onClose: function() {
          $(document.activeElement).blur();
        },
      }).off('focus').on("change", function() {
        if ($('.request-price-form .date-from').val() && $('.request-price-form .date-to').val()) {
          $('.request-price-form').submit();
          $('.-disabled').hide();
          // Analytics Tracking
          gtag(
            'event', 'Toolteiler :: Buchungsbox', {
            'event_category': 'Toolteiler',
            'event_label': 'Auswahl :: Zeitraum'
          });
        }
      });

    }

    return {
      init: init
    };

})();
