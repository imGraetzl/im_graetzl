APP.controllers.graetzls = (function() {

    var map =  APP.components.graetzlMap;

    function init() {
        var mapvisible= jQuery('section.graetzls').data('mapvisible');
        map.init(function() {
                map.showMapGraetzl(mapvisible.graetzls, null, {
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