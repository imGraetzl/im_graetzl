APP.controllers.tool_demands = (function() {

  function init() {
    if ($("section.tool-demand").exists()) { initToolDemand(); }
  }

  function initToolDemand() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();
  }

  return {
    init: init
  }

  })();
