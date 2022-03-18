APP.controllers_loggedin.crowd_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.amount-screen").exists())  {initAmountScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-pledges-page.summary-screen").exists()) {initSummaryScreen();}
    }

    function initAmountScreen() {
      APP.components.tabs.setTab('step1');

      $(".calculate-price").on("focusout", function() {
        var submit_url = $(this).data('action');
        var amount = $(this).val();
        $.ajax({
            type: "POST",
            url: submit_url,
            data: "amount=" + amount
        });
      });
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');

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

      var screen = $(".crowd-pledges-page.payment-screen");
        screen.find(".paymentMethods input").on("click", function() {
        screen.find(".payment-method-container").hide();
        screen.find("." + $(this).val() + "-container").show();
      });

      screen.find(".paymentMethods input:checked").click();

      if ($(".card-container").exists()) { initCardPayment(); }
      if ($(".eps-container").exists()) { initEpsPayment(); }

    }

    function initCardPayment() {
      var cardForm = $(".card-container .card-form");
      APP.components.paymentCardSetup.init(cardForm);
      cardForm.on('payment:complete', function() {
        location.href = $(this).data('success-url');
      });
    }

    function initEpsPayment() {
      var epsForm = $(".eps-container .eps-form");
      APP.components.paymentEps.init(epsForm);
    }

    function initSummaryScreen() {

    }

    return {
      init: init
    };

})();
