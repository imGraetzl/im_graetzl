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

    function init(callback, options) {
        map = L.map('graetzlMapWidget', {
            layers: [mainLayer],
            dragging: false,
            touchZoom: false,
            scrollWheelZoom: false,
            doubleClickZoom: false,
            boxZoom: false,
            tap: false
        }).setActiveArea('activeArea');
        callback();
    }


    function showMapDistrict(districts, options) {
        var config = $.extend({}, defaults, options);
        var districtMap = L.geoJson(districts, {
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
                        $('.mapInfoText').html('<div class="districtNumber">' + feature.properties.zip + ' . Bezirk</div> <div class="districtName">' + feature.properties.name + '</div>');
                    });
                    layer.on('mouseout', function () {
                        districtMap.resetStyle(layer);
                        $('.mapInfoText').empty();
                    });
                }
            }
        });

        map.addLayer(districtMap, true);
        if(config.zoomAfterRender) {
            map.fitBounds(districtMap.getBounds());
        }
        return this;
    }


    function showMapGraetzl(graetzls, options) { // Array or String
        var config = $.extend({}, defaults, options);
        var graetzlMap = L.geoJson(graetzls, {
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


