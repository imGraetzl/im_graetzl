APP.controllers.room_calls = (function() {

  function init() {
    if ($("section.room-call-form").exists()) initRoomForm();
    afterRegistration();
    afterCallSubmit();
  }

  // Change Wording of Notice Message for Call Registrations
  function afterRegistration() {
    if ($("#flash .notice").exists()) {
      if ( $("#flash .notice").text().indexOf('Vielen Dank für Deine Registrierung') >= 0 ){
        // Modifiy Message for Call
        $("#flash .notice").html('Vielen Dank für Deine Registrierung. Du bist nun angemeldet und kannst das <a href="#call">Call Formular</a> (unterhalb) ausfüllen.');
      }
    }
  }
  // Analytics Event Tracking for Call Submission
  function afterCallSubmit() {
    if ($("#flash .notice").exists()) {
      if ( $("#flash .notice").text().indexOf('Danke für deine Bewerbung') >= 0 ){
        var pathArray = window.location.pathname.split('/');
        var callSlug = pathArray.slice(-1)[0];
        // GA
        gtag('event', 'call', {'event_category': 'Call completed', 'event_label': callSlug});
      }
    }
  }

  // Leaflet MAP
  if ($("#map").exists()) {
    var x = $("#map").data("x");
    var y = $("#map").data("y");
    var $markerHtml = $(".map-avatar").html();
    var marker = L.divIcon({className: 'marker-container', html: $markerHtml});
    var map = L.map('map', {
      tap: false,
      scrollWheelZoom:false,
      zoomControl:false,
    }).setView([y, x], 16);
    L.tileLayer.provider('MapBox', { id: 'malano78/ckgcmiv6v0irv19paa4aoexz3', accessToken: 'pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw'}).addTo(map);
    L.control.zoom({position:'bottomright'}).addTo(map);
    L.marker([y, x], {icon: marker}).addTo(map);
  }

  function initRoomForm() {
    APP.components.addressSearchAutocomplete();
    APP.components.search.userAutocomplete();

    $('.datepicker').pickadate({
      formatSubmit: 'yyyy-mm-dd',
      hiddenName: true
    });

  }

  return {
    init: init,
  }

})();
