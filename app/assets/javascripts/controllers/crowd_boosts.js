APP.controllers.crowd_boosts = (function() {

    function init() {
        if ($("section.crowd_boost").exists()) initCrowdBoost();
        if ($("section.crowd_boost .new_contact_list_entry").exists()) initForm();
        if ($("section.boost_call").exists()) initCrowdHotAugust();
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

    function initForm() {
        if($("#error_explanation").exists()) {
          $('html, body').animate({
            scrollTop: $('#error_explanation').offset().top
          }, 600);
        }
    }

    function initCrowdHotAugust() {

      $(".form-charges").submit();

    }

    return {
      init: init
    };

})();
