APP.controllers.posts = (function() {

    var map =  APP.components.graetzlMap;
    var filter = APP.components.startpageFilter;

    function init() {
        filter.init();
        var mapdata = $('#graetzlMapWidget').data('mapdata');
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

    return {
        init: init
    }

})();
