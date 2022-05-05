APP.controllers_loggedin.crowd_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.amount-screen").exists())  {initAmountScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-pledges-page.summary-screen").exists()) {initSummaryScreen();}
      else if ($(".crowd-pledges-page.change-payment-screen").exists()) {initPaymentChangeScreen();}

    }

    function initAmountScreen() {
      APP.components.tabs.setTab('step1');
      initAmount();
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');
      initAmount();

      // Change Wording of Notice Message for CrowdPledge Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Vielen Dank für Deine Registrierung') >= 0){
          $("#flash .notice").text('Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet und kannst fortfahren..');
        }
      }
    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step3');
      APP.components.stripePayment.init();
    }

    function initPaymentChangeScreen() {
      APP.components.stripePayment.init();
    }

    function initAmount() {
      $(".calculate-price").on("focusout", function() {
        var submit_url = $(this).data('action');
        var donation_amount = $(this).val();
        $.ajax({
            type: "POST",
            url: submit_url,
            data: "donation_amount=" + donation_amount
        });
      });
    }

    function initSummaryScreen() {

    }

    return {
      init: init
    };

})();
