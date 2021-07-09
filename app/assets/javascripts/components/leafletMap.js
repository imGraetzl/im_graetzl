APP.components.leafletMap = (function() {

  function init() {

    if ($("#leafletMap").exists()) {

      var x = $("#leafletMap").data("x");
      var y = $("#leafletMap").data("y");
      var $markerHtml = $(".map-avatar").html();
      //var $popupHtml =  $(".map-popup").html();
      //var popup = L.popup().setLatLng([y, x]).setContent($popupHtml);
      var marker = L.divIcon({className: 'marker-container', html: $markerHtml});
      var map = L.map('leafletMap', {
        tap: false,
        scrollWheelZoom:false,
        zoomControl:false,
      }).setView([y, x], 16);
      L.tileLayer.provider('MapBox', { id: 'malano78/ckgcmiv6v0irv19paa4aoexz3', accessToken: 'pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw'}).addTo(map);
      L.control.zoom({position:'bottomright'}).addTo(map);
      L.marker([y, x], {icon: marker}).addTo(map);
      //L.marker([y, x], {icon: marker}).addTo(map).bindPopup(popup);

    }

  }

  return {
      init: init
  }

})();
