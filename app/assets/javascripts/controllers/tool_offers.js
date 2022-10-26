APP.controllers.tool_offers = (function() {

    function init() {
      if ($("section.toolTeiler-detail").exists()) { initToolOfferDetails(); }
    }

    function initToolOfferDetails() {

      if ($("#leafletMap").exists()) APP.components.leafletMap.init($('#leafletMap'));

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
            'event', 'Geräteteiler :: Buchungsbox', {
            'event_category': 'Geräteteiler',
            'event_label': 'Auswahl :: Zeitraum'
          });
        }
      });

    }

    return {
      init: init
    };

})();
