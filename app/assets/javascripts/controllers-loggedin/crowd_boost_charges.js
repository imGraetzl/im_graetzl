APP.controllers_loggedin.crowd_boost_charges = (function() {

    function init() {
      if ($(".crowd-boost-charge-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-boost-charge-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-boost-charge-page.detail-screen").exists()) {initDetailScreen();}
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step1');

      // Change Wording of Notice Message for CrowdBoostCharge Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Vielen Dank für Deine Registrierung') >= 0){
          $("#flash .notice").text('Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet und kannst mit deiner Einzahlung fortfahren..');
        }
        else if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deiner Einzahlung.');
        }
      }
    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step2');
      APP.components.stripePayment.init();
    }

    function initDetailScreen() {
      $('.-charge-details-toggle').on('click', function() {
        $('.-charge-details').slideToggle();
      });
    }

    return {
      init: init
    };

})();
