APP.controllers.zuckerls = (function() {

    function init() {
        APP.components.createzuckerl.init();
        if($("section.startpage").exists()) initZuckerlsOverview();
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
