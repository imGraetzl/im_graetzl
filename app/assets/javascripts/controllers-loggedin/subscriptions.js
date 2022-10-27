APP.controllers_loggedin.subscriptions = (function() {

    function init() {
      if      ($(".subscriptions-page.address-screen").exists())  {initAddressScreen();}
      else if ($(".subscriptions-page.payment-screen").exists()) {initPaymentScreen();}
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step1');
    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step2');
      APP.components.stripePayment.init();
    }

    return {
      init: init
    };

})();
