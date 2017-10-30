APP.controllers.wien = (function() {

    var map = APP.components.graetzlMap;

    function init() {
        var $select = $(".mapImgBlock .mobileSelectMenu");
        $(".mapImgBlock .links a").each(function() {
            var text = $(this).text();
            var target = $(this).attr("href");
            $select.append("<option value="+target+">"+text+"</option>");
        });
        $select.on("change", function() {
            window.location.href = $(this).val();
        });

        APP.components.addressSearchAutocomplete();

        if ($("#graetzlMapWidget").exists()) {
          initMap();
        }

        $('.autosubmit-filter').submit();
    }

    // ---------------------------------------------------------------------- section inits

    function initMap() {
        var mapdata = $('#graetzlMapWidget').data('mapdata');
        map.init(function() {
            map.showMapDistrict(mapdata.districts, {
                interactive: true
            });
        });
    }

    // ---------------------------------------------------------------------- public

    return {
        init: init
    }

})();
