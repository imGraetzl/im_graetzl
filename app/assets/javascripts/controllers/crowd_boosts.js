APP.controllers.crowd_boosts = (function() {

    function init() {
        if ($("section.crowd_boost").exists()) initCrowdBoost();
        if ($("section.hot_august").exists()) initCrowdHotAugust();
    }

    function initCrowdBoost() {

      APP.components.tabs.initTabs(".tabs-ctrl", "#tabs-container");

      // Load on Tab Change & PageLoad
      $('.tabs-ctrl').on("_after", function() {
        if ($("#tab-campaigns").is(":visible")) {
          APP.components.cardBoxFilter.submitForm();
        } else if ($("#tab-charges").is(":visible")) {
          $(".form-charges").submit();
        }
      }).trigger('_after');

    }

    function initCrowdHotAugust() {

      $(".form-charges").submit();

    }

    return {
      init: init
    };

})();
