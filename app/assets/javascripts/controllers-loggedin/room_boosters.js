APP.controllers_loggedin.room_boosters = (function() {

    function init() {
      if ($(".room-booster-page.address-screen").exists()) {
        initAddressScreen();
      } else if ($(".room-booster-page.payment-screen").exists()) {
        initPaymentScreen();
      } else if ($(".room-booster-page.summary-screen").exists()) {
        initSummaryScreen();
      }
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step1');
    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step2');
      APP.components.stripePayment.init();
    }

    function initSummaryScreen() {

    }

    return {
      init: init
    };

})();
