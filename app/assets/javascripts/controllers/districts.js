APP.controllers.districts = (function() {

    var map =  APP.components.graetzlMap;

    function init() {
        if($('section.vienna').exists()){
            map.init(function() {
                    map.showMapDistrict(null, {
                        interactive: true
                    });
                }
            );
        }


        if($('section.districts').exists()){
            console.log("jkjk");
            var mapvisible= jQuery('section.districts').data('mapvisible');
            map.init(function() {
                    map.showMapDistrict(mapvisible.districts, {
                        style: $.extend(map.styles.mint, {
                            weight: 0,
                            fillOpacity: 0.5
                        })
                    });
                    map.showMapGraetzl(null, mapvisible.districts, {
                        interactive: true,
                        zoomAfterRender: false
                    });
                }
            )
        }



    }

    return {
        init: init
    }

})();