APP.controllers.zuckerls = (function() {

    function init() {
        if($("section.masonryFilterGrid").exists()) initZuckerlsOverview();
        APP.components.createzuckerl.init();
    }

    function initZuckerlsOverview() {
        var filter = APP.components.masonryFilterGrid;
        var map =  APP.components.graetzlMap;
        var mapdata = $('#graetzlMapWidget').data('mapdata');

        filter.init();
        map.init(function() {
                map.showMapGraetzl(mapdata.graetzls, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
