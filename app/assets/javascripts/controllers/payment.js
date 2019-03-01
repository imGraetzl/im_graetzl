APP.controllers.payment = (function() {

  function init() {
    APP.components.stripeCheckout.init();
  }

  return {
    init: init
  };

})();
