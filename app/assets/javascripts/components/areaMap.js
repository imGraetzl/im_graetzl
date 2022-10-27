//= require leaflet
//= require leaflet-providers
//= require leaflet.activearea

APP.components.areaMap = (function() {
  var styles = {
    rose: {
      color: '#F37468',
      fill: '#F37468',
      opacity: 1,
      weight: 2,
      fillOpacity: 0.1
    },
    over: {
      fillOpacity: 0.8
    },
    default: {
      color: '#93CFC6',
      fill: '#93CFC6',
      weight: 1,
      opacity: 0.8,
      fillOpacity: 0.2
    },
    active: {
      color: '#F37468',
      fill: '#F37468',
      weight: 1,
      opacity: 0.7,
      fillOpacity: 0.3
    },
    home: {
      color: '#69a8a7',
      fill: '#69a8a7',
      weight: 1,
      opacity: 0.7,
      fillOpacity: 0.6
    },
    hover: {
      weight: 1,
      opacity: 1,
      fillOpacity: 0.5,
    },
  };

  var mainLayer = L.tileLayer.provider('MapBox', {
      id: 'malano78/ckt4d1tal0y9u17o5sn6y0jp4',
      accessToken: 'pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw',
    }
  );

  // Reduce Resolution on Mobile Defices / Remove @x2 Image Attribute
  if (L.Browser.mobile) {
    mainLayer.options.r = ''
  }

  // FAVORITE GRAETZL MAP ------------------

  function initFavoriteGraetzls(mapElement, options) {
    options = options || {};

    var map = L.map(mapElement.attr('id'), {
        layers: [mainLayer],
        dragging: true,
        touchZoom: true,
        scrollWheelZoom: false,
        doubleClickZoom: false,
        boxZoom: false,
        tap: false,
        zoomSnap: 1,
        zoomControl: false,
        minZoom: 10,
        maxZoom: 16,
    }).setActiveArea('activeArea');
    L.control.zoom({position:'bottomright'}).addTo(map);

    var defaultStyle = styles[options.style || 'default'];

    // Set Favorite Graetzl Map Layer
    var initFavorites = mapElement.data("areas").features.filter(function(value, index, arr){
        return value.properties.favorite || value.properties.home;
    });
    var favoritesLayer = L.geoJson({type:"FeatureCollection", features:initFavorites});

    var areaLayer = L.geoJson(mapElement.data("areas"), {
      style: defaultStyle,
      onEachFeature: function (feature, layer) {

        // Set Home
        if (feature.properties.home) {
          layer.setStyle(styles.home);
          listAdd(feature, layer, styles.home, false, '.home-graetzl');
        }

        // Set Favorites
        if (feature.properties.favorite) {
          layer.setStyle(styles.active);
          listAdd(feature, layer, styles.active, true, '.favorite-graetzls');
        }

        layer.on('click', function () {
            if (this.feature.properties.home) { return; }
            if (this.feature.properties.favorite) {
              this.feature.properties.favorite = false;
              areaLayer.resetStyle(layer);
              listRemove(feature);
            }
            else {
              this.feature.properties.favorite = true;
              this.setStyle(styles.active);
              listAdd(feature, layer, styles.active, true, '.favorite-graetzls');
            }
        });

        layer.on('mouseover', function () {
            highlightMapNav(feature.properties.id);
            if (this.feature.properties.home) { return; }
            this.setStyle(styles.hover);
        });

        layer.on('mouseout', function () {
            unhighlightMapNav(feature.properties.id);
            if (this.feature.properties.home) { return; }
            if (this.feature.properties.favorite) {
              this.setStyle(styles.active)
            }
            else {
              areaLayer.resetStyle(layer)
            }
        });
      }
    });

    map.addLayer(areaLayer, true);
    if ($('body').data('region') == 'wien') {
      map.fitBounds(favoritesLayer.getBounds());
    } else {
      map.fitBounds(areaLayer.getBounds());
    }
  }

  // STANDARD MAPS ------------------

  function init(mapElement, options) {
    options = options || {};

    if (options.mapLayer) {
      mainLayer.options.id = options.mapLayer;
    }

    var map = L.map(mapElement.attr('id'), {
        layers: [mainLayer],
        dragging: false,
        touchZoom: false,
        scrollWheelZoom: false,
        doubleClickZoom: false,
        boxZoom: false,
        tap: false,
        zoomSnap: options.zoomSnap || 1,
    }).setActiveArea('activeArea');

    var defaultStyle = styles[options.style || 'rose'];

    var areaLayer = L.geoJson(mapElement.data("areas"), {
      style: defaultStyle,
      onEachFeature: function (feature, layer) {
        if (!options.interactive) { return; }

        handlehighlightMapPoly(layer, feature, styles.over, styles.rose);

        layer.on('click', function () {
            window.location.href = feature.properties.url;
        });
        layer.on('mouseover', function () {
          this.setStyle(styles.over)
          highlightMapNav(feature.properties.id);
        });
        layer.on('mouseout', function () {
          areaLayer.resetStyle(layer)
          unhighlightMapNav(feature.properties.id);
        });
      }
    });

    map.addLayer(areaLayer, true);
    map.fitBounds(areaLayer.getBounds());
  }

  // HELPER FUNCTIONS ------------------

  function highlightMapNav(k) {
    $(".navBlock .links").find('a[data-id="'+ k + '"]').addClass('is-highlighted');
  }

  function unhighlightMapNav(k) {
    $(".navBlock .links").find('a[data-id="'+ k + '"]').removeClass('is-highlighted');
  }

  function handlehighlightMapPoly(layer, feature, over, out, remove) {
    $(".navBlock .links").find('a[data-id="'+ feature.properties.id + '"]').on("mouseover", function() {
      layer.setStyle(over)
    }).on("mouseout", function() {
      layer.setStyle(out)
    });
    if (remove) {
      $(".navBlock .links").find('a[data-id="'+ feature.properties.id + '"]').on("click", function() {
        $(".navBlock .links").find('a[data-id="'+ feature.properties.id + '"]').fadeOut(200, function() {
          $(this).remove();
        });
        layer.setStyle(styles.default);
        layer.feature.properties.favorite = false;
      })
    }
  }

  function listAdd(feature, layer, reset_style, remove, append_to) {
    var list = $(".links" + append_to);
    if (!list.find("[data-id="+feature.properties.id+"]").exists()) {
      var item = $("<a href='javascript:' data-id="+feature.properties.id+">"+feature.properties.plz+""+feature.properties.name+"</a>");
      item.prependTo(list).hide().fadeIn();
    }
    handlehighlightMapPoly(layer, feature, styles.hover, reset_style, remove);
  }

  function listRemove(feature) {
    $("[data-id="+feature.properties.id+"]").fadeOut(400, function() {
      $(this).remove();
    });
  }

  return {
    init: init,
    initFavoriteGraetzls: initFavoriteGraetzls,
  }

})();
