APP.controllers.districts = (function() {

    var map = APP.components.graetzlMap;

    function init() {
        var $select = $(".mapImgBlock .mobileSelectMenu");
        $(".mapImgBlock .links a").each(function() {
            var text = $(this).text();
            var target = $(this).attr("href");
            $select.append("<option value="+target+">"+text+"</option>");
            //$(".mapImgBlock .links").after($select);
        });
        $select.on("change", function() {
            window.location.href = $(this).val();
        });

        initMap();
    }

    // ---------------------------------------------------------------------- section inits

    function initMap() {
        var mapdata = $('#graetzlMapWidget').data('mapdata');
        map.init(function() {
            map.showMapDistrict(mapdata.districts, {
                style: $.extend(map.styles.mint, {
                    weight: 0,
                    fillOpacity: 0.5
                })
            });
            map.showMapGraetzl(mapdata.graetzls, {
                interactive: true,
                zoomAfterRender: false
            });
        }
        );

        APP.components.cardBox.moveActionCard3rd();

    }

    // ---------------------------------------------------------------------- public

    return {
        init: init
    }

})();
