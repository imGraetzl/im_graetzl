APP.controllers.graetzls = (function() {

    function init() {
      initFilter();
    }

    function initFilter() {

      if ($('.cards-filter').exists()) {
        APP.components.cardBoxFilter.init();
      }

      if ($("section.rooms, section.meetings, section.locations, section.coop-demands").exists()) {
        APP.components.categoryFilter.init($('#category-slider'));
      }

    }

    return {
      init: init
    };

})();
