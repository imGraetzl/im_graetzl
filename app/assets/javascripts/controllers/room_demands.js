APP.controllers.room_demands = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
    if ($("section.roomDetail").exists()) { initRoomDetail(); }
  }

  function initRoomDetail() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();
  }


  function initRoomForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    $("textarea").autogrow({ onInitialize: true });

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

  }

  return {
    init: init
  }


  })();
