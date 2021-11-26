APP.controllers.coop_demands = (function() {

  function init() {
    if ($("section.coop-demand").exists()) { initCoopDemand(); }
  }

  function initCoopDemand() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();
  }

  return {
    init: init
  }

  })();
