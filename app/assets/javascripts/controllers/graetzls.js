APP.controllers.graetzls = (function() {

    function init() {
      initMap();
      initFilter();
    }

    function initMap() {
      APP.components.areaMap.init($('#area-map'));
    }

    function initFilter() {
      if ($("#filter-modal-bezirk").exists()) {
        APP.components.graetzlSelectFilter.init($("#filter-modal-bezirk"));
      }

      if ($('.cards-filter').exists()) {
        APP.components.cardBoxFilter.init();
      }

      if ($("section.toolteiler, section.rooms, section.meetings, section.locations, section.coop-demands").exists()) {
        APP.components.categoryFilter.init($('#category-slider'));
      }

    }

    return {
      init: init
    };

})();
