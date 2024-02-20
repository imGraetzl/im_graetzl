APP.controllers.energy_offers = (function() {

  function init() {
    if ($("section.-energyOffer").exists()) { initEnergyDetail(); }
  }

  function initEnergyDetail() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();
  }

  return {
    init: init
  }


  })();
