APP.controllers.room_demands = (function() {

  function init() {
    if ($("section.roomDetail").exists()) { initRoomDetail(); }
  }

  function initRoomDetail() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();
  }

  return {
    init: init
  }


  })();
