APP.controllers_loggedin.zuckerls = (function() {

    function init() {
      if ($(".zuckerl-page.createzuckerl").exists()) {
        initFormScreen();
      } else if ($(".zuckerl-page.address-screen").exists()) {
        initAddressScreen();
      } else if ($(".zuckerl-page.payment-screen").exists()) {
        initPaymentScreen();
      } else if ($(".zuckerl-page.change-payment-screen").exists()) {
        initPaymentChangeScreen();
      } else if ($(".zuckerl-page.summary-screen").exists()) {
        initSummaryScreen();
      }
    }

    function initFormScreen() {
      APP.components.tabs.setTab('step1');
      APP.components.createzuckerl.init();
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');
    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step3');
      APP.components.stripePayment.init();
    }

    function initPaymentChangeScreen() {
      APP.components.stripePayment.init();
    }

    function initSummaryScreen() {

    }

    return {
      init: init
    };

})();
