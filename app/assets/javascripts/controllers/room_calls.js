APP.controllers.room_calls = (function() {

  function init() {
    if ($("section.room-call-form").exists()) initRoomForm();
    afterRegistration();
    afterCallSubmit();
    if ($("#leafletMap").exists()) APP.components.leafletMap.init($('#leafletMap'));
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
