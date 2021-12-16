APP.controllers_loggedin.tool_rentals = (function() {

    function init() {
      if ($(".tool-rental-page.address-screen").exists()) {
        initAddressScreen();
      } else if ($(".tool-rental-page.payment-screen").exists()) {
        initPaymentScreen();
      } else if ($(".tool-rental-page.summary-screen").exists()) {
        initSummaryScreen();
      }
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step1');

      // Change Wording of Notice Message for Toolteiler Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Vielen Dank für Deine Registrierung') >= 0){
          // Modifiy Message for Toolteiler Registrations
          $("#flash .notice").text('Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet und kannst mit deiner Toolteiler Anfrage fortfahren..');
        }
      }

    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step2');

      var screen = $(".tool-rental-page.payment-screen");
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
      APP.components.paymentCard.init(cardForm);
      cardForm.on('payment:complete', function() {
        location.href = $(this).data('success-url');
      });
    }

    function initEpsPayment() {
      var epsForm = $(".eps-container .eps-form");
      APP.components.paymentEps.init(epsForm);
    }

    function initSummaryScreen() {
      APP.components.tabs.setTab('step3');
    }

    return {
      init: init
    };

})();
