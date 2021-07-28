APP.components.areaMap = (function() {
  var styles = {
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
  };

  function init(mapElement, options) {
    options = options || {};

    var mainLayer = L.tileLayer.provider('MapBox',
      { id: 'malano78/ckgcmiv6v0irv19paa4aoexz3', accessToken: 'pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw'}
    );
    var map = L.map(mapElement.attr('id'), {
        layers: [mainLayer],
        dragging: false,
        touchZoom: false,
        scrollWheelZoom: false,
        doubleClickZoom: false,
        boxZoom: false,
        tap: false
    }).setActiveArea('activeArea');

    var defaultStyle = styles[options.style || 'rose'];

    var areaLayer = L.geoJson(mapElement.data("areas"), {
      style: defaultStyle,
      onEachFeature: function (feature, layer) {
        if (!options.interactive) { return; }

        handlehighlightMapPoly(layer, feature.properties.url);

        layer.on('click', function () {
            window.location.href = feature.properties.url;
        });
        layer.on('mouseover', function () {
          this.setStyle(styles.over)
          highlightMapNav(feature.properties.url);
        });
        layer.on('mouseout', function () {
          areaLayer.resetStyle(layer)
          unhighlightMapNav(feature.properties.url);
        });
      }
    });

    map.addLayer(areaLayer, true);
    map.fitBounds(areaLayer.getBounds());
  }

  function highlightMapNav(k) {
    $(".navBlock .links").find('a[href*="'+ k + '"]').addClass('is-highlighted');
  }

  function unhighlightMapNav(k) {
    $(".navBlock .links").find('a[href*="'+ k + '"]').removeClass('is-highlighted');
  }

  function handlehighlightMapPoly(layer, k) {
    $(".navBlock .links").find('a[href*="'+  k + '"]').on("mouseover", function() {
      layer.setStyle(styles.over)
    }).on("mouseout", function() {
      layer.setStyle(styles.rose)
    });
  }

  return {
    init: init,
  }

})();