APP.controllers.room_calls = (function() {

  function init() {
    if ($("section.room-call-form").exists()) initRoomForm();
    afterRegistration();
    afterCallSubmit();
    APP.components.leafletMap.init($('#leafletMap'));
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

  function initRoomForm() {
    APP.components.addressInput();
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
