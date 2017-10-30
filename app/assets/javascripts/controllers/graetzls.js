APP.controllers.graetzls = (function() {

    var map =  APP.components.graetzlMap;
    var filter = APP.components.masonryFilterGrid;

    function init() {
      initMap();
      initContentStream();
    }

    function initMap() {
      var mapdata = $('#graetzlMapWidget').data('mapdata');
      map.init(function() {
        map.showMapGraetzl(mapdata.graetzls, {
          style: $.extend(map.styles.rose, { weight: 4, fillOpacity: 0.2 })
        });
      });
    }

    function initContentStream() {
      filter.init();
      $('.autosubmit-filter').submit();
    }

    return {
      init: init
    };

})();
