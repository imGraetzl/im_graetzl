APP.components.graetzlMap = (function() {
    var map,
        geoVienna,
        geoGraetzl,
    // mainLayer =  L.tileLayer.provider('Stamen.Watercolor'),
        mainLayer = L.tileLayer.provider('MapBox', { id: 'peckomingo.lb8m2cga', accessToken: 'pk.eyJ1IjoicGVja29taW5nbyIsImEiOiJoVHNQM29zIn0.AVmpyDYApR5mryMCJB1ryw'}),

        styles = {
            mint: {
                color: '#93CFC6',
                fill: '#93CFC6',
                opacity: 1,
                weight: 2,
                fillOpacity: 0.1
            },
            over: {
                fillOpacity: 0.8
            },
            rose: {
                color: '#F37468',
                fill: '#F37468',
                opacity: 1,
                weight: 2,
                fillOpacity: 0.1
            }
        },

        defaults = {
            interactive: false,
            zoomAfterRender: true,
            style: styles.rose
        };




    function init(callback) {
        $.when($.getJSON('/assets/javascripts/graetzls.json'), $.getJSON('/assets/javascripts/districts.json')).done(function(featureGraetzl, featureDistrict) {
                geoGraetzl = featureGraetzl[0];
                geoVienna = featureDistrict[0];
                map = L.map('graetzlMapWidget', {
                    layers: [mainLayer],
                    dragging: false,
                    touchZoom: false,
                    scrollWheelZoom: false,
                    doubleClickZoom: false,
                    boxZoom: false,
                    tap: false
                }).setActiveArea('activeArea');

                $(document).on("page:before-unload", function() {
                    if (_.isFunction(map.remove)) {
                        console.log("sss");
                        map.remove();
                    }
                });

                callback();
            }
        );
    }


    function showMapDistrict(districts, options) {
        var config = $.extend({}, defaults, options);
        var districtMap = L.geoJson(geoVienna, {
            style: function () {
                return config.style
            },
            onEachFeature: function (feature, layer) {
                if (config.interactive) {
                    layer.on('click', function () {
                        console.log(feature.properties.targetURL);
                        window.location.href = feature.properties.targetURL;
                    });
                    layer.on('mouseover', function () {
                        this.setStyle(styles.over);
                        $('.mapInfoText').html('<div class="districtNumber">' + feature.properties.BEZNR + ' . Bezirk</div> <div class="districtName">' + feature.properties.NAMEK + '</div>');
                    });
                    layer.on('mouseout', function () {
                        districtMap.resetStyle(layer);
                        $('.mapInfoText').empty();
                    });
                }
            },
            filter: function(feature, layer) {
                if (districts != null || districts != undefined) {
                    for (var i = 0; i < districts.length; i++) {
                        if (feature.properties.BEZNR == districts[i]) {
                            return true;
                        }
                    }
                } else {
                    return true;
                }
            }
        });

        map.addLayer(districtMap, true);
        if(config.zoomAfterRender) {
            map.fitBounds(districtMap.getBounds());
        }
        return this;
    }


    function showMapGraetzl(visibleGraetzl, inDistricts, options) { // Array or String
        var config = $.extend({}, defaults, options);
        var graetzlMap = L.geoJson(geoGraetzl, {
            style: function() {
                return config.style;
            },
            onEachFeature: function (feature, layer) {
                if (config.interactive) {
                    layer.on('click', function () {
                        window.location.href = feature.properties.targetURL;
                    });
                    layer.on('mouseover', function () {
                        this.setStyle(styles.over);
                        $('.mapInfoText').html('<div class="graetzlName">' + feature.properties.name + '</div>');
                    });
                    layer.on('mouseout', function () {
                        graetzlMap.resetStyle(layer);
                        $('.mapInfoText').empty();
                    });
                }
            },
            filter: function(feature, layer) {
                if (visibleGraetzl != null || visibleGraetzl != undefined) {
                    for (var i = 0; i < visibleGraetzl.length; i++) {
                        if (feature.properties.graetzlID == visibleGraetzl[i]) {
                            return true;
                        }
                    }
                }
                if (inDistricts != null || inDistricts != undefined) {
                    for (var i = 0; i < inDistricts.length; i++) {
                        if(feature.properties.districts && feature.properties.districts.indexOf(inDistricts[i]) > -1) {
                            return true;
                        }
                    }
                }
            }
        });

        map.addLayer(graetzlMap);
        if(config.zoomAfterRender == true) {
            map.fitBounds(graetzlMap.getBounds());
        }
        return this;
    }


    function getMap() {
        return map;
    }

    return {
        styles: styles,
        init: init,
        showMapGraetzl: showMapGraetzl,
        showMapDistrict: showMapDistrict,
        getMap: getMap
    }


})();


