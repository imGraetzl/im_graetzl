APP.controllers_loggedin.zuckerls = (function() {

    function init() {
      if ($(".zuckerl-page.createzuckerl").exists()) {
        initFormScreen();
      } else if ($(".zuckerl-page.voucher-screen").exists()) {
        initVoucherScreen();
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
      APP.components.formHelper.maxChars();

      $('.starts_at').pickadate({
        formatSubmit: 'yyyy-mm-dd',
        format: 'd. mmm, yyyy',
        hiddenName: true,
        min: 1,
        max: 365,
        onSet: function(context) {
          if (typeof context.select !== 'undefined') {
            var enddate = new Date(context.select);
            enddate.setMonth(enddate.getMonth() + 1);
            $('.ends_at').pickadate('picker').set('select', enddate - 1); // 1 Month after Startdate
          }
        },
      });

      $('.ends_at').pickadate({
        formatSubmit: 'yyyy-mm-dd',
        format: 'd. mmm, yyyy',
        hiddenName: true,
      });

    }

    function initVoucherScreen() {
      APP.components.tabs.setTab('step2');
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
