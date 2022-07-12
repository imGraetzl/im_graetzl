APP.controllers_loggedin.tool_rentals = (function() {

    function init() {
      if ($(".tool-rental-page.address-screen").exists()) {
        initAddressScreen();
      } else if ($(".tool-rental-page.payment-screen").exists()) {
        initPaymentScreen();
      } else if ($(".tool-rental-page.change-payment-screen").exists()) {
        initPaymentChangeScreen();
      } else if ($(".tool-rental-page.summary-screen").exists()) {
        initSummaryScreen();
      } else if ($(".tool-rental-page.login-screen").exists()) {
        initLoginScreen();
      }
    }

    function initLoginScreen() {
      // Change Wording of Notice Message for Toolteiler Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          // Modifiy Message for Toolteiler Registrations
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deiner Toolteiler Anfrage.');
        }
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
      APP.components.stripePayment.init();
    }

    function initPaymentChangeScreen() {
      APP.components.stripePayment.init();
    }

    function initSummaryScreen() {
      APP.components.tabs.setTab('step3');
    }

    return {
      init: init
    };

})();
