APP.components.leafletMap = (function() {

  function init(mapElement, options) {

    options = options || {};
    var defaultZoom = options.zoom || 16;

    var x = mapElement.data("x");
    var y = mapElement.data("y");

    var map = L.map(mapElement.attr('id'), {
      tap: false,
      scrollWheelZoom:false,
      zoomControl:false,
    }).setView([y, x], defaultZoom);
    L.tileLayer.provider('MapBox', { id: 'malano78/ckgcmiv6v0irv19paa4aoexz3', accessToken: 'pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw'}).addTo(map);
    L.control.zoom({position:'bottomright'}).addTo(map);

    // Add Markers to Map
    mapElement.find($(".map-marker")).each(function(){
      console.log($(this).attr("class"));
      var $markerHtml = $(this).html();
      var marker = L.divIcon({className: 'marker-container', html: $markerHtml});
      var markerX = $(this).data("x") || x;
      var markerY = $(this).data("y") || y;
      L.marker([markerY, markerX], {icon: marker}).addTo(map);
    });

  }

  return {
      init: init
  }

})();
