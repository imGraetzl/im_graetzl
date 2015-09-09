APP.controllers.districts = (function() {

    var map =  APP.components.graetzlMap;

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


        // gets called on index
        if($('section.vienna').exists()){
            console.log("SELECT VIENNA FUNCTION");
            var districts = jQuery('section.vienna').data('map');
            map.init(function() {
                map.showMapDistrict(null, {
                    interactive: true
                });
                }, {districts: districts}
            );
            // var url= jQuery('section.vienna').data('url');
            // $.when($.getJSON(url)).done(function(districts) {

            //     map.init(function() {
            //             map.showMapDistrict(null, {
            //                 interactive: true
            //             });
            //         }, {districts: districts}
            //     );
            // });
        }


        if($('section.districts').exists()){
            console.log("SELECT DISTRICTS");
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