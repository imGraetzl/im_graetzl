APP.controllers.graetzls = (function() {

    function init() {
      initMap();
      initFilter();
      initSlider();
      initJBox();
    }

    function initSlider() {
      APP.components.cardSlider.init($("#card-slider"));
    }

    function initMap() {
      APP.components.areaMap.init($('#area-map'));
    }

    function initFilter() {
      if ($("#filter-modal-bezirk").exists()) {
        APP.components.graetzlSelectFilter.init($("#filter-modal-bezirk"));
      }

      if ($('.cards-filter').exists()) {
        APP.components.cardFilter.init();
      }

      if ($("section.toolteiler, section.rooms, section.meetings, section.locations").exists()) {
        APP.components.cardFilterSlider.init($('#category-slider'));
      }

    }

    function initJBox() {
      var mobCreate = new jBox('Modal', {
        addClass:'jBox',
        attach: '.mob #createContent',
        content: $('#jBoxCreateContent'),
        trigger: 'click',
        closeOnClick:true,
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });
      var deskCreate = new jBox('Tooltip', {
        addClass:'jBox',
        attach: '.desk #createContent',
        content: $('#jBoxCreateContent'),
        trigger: 'click',
        closeOnClick:true,
        pointer:'right',
        adjustTracker:true,
        isolateScroll:true,
        adjustDistance: {top: 25, right: 25, bottom: 25, left: 25},
        animation:{open: 'zoomIn', close: 'zoomOut'},
        maxHeight:500,
      });
    }

    return {
      init: init
    };

})();
