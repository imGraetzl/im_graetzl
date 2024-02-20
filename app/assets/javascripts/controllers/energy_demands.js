APP.controllers.energy_demands = (function() {

  function init() {
    if ($("section.energy-demand").exists()) { initEnergyDetail(); }
  }

  function initEnergyDetail() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();
  }

  return {
    init: init
  }


  })();
