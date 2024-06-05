APP.controllers_loggedin.crowd_boost_charges = (function() {

    function init() {
      if ($(".crowd-boost-charge-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-boost-charge-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-boost-charge-page.detail-screen").exists()) {initDetailScreen();}
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step1');
      initAmount();

      $(".toggle-collapsed").on("focusin", function() {
        $(".collapsed").slideDown();
      });

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

    function initAmount() {
      // Set Amount on Input
      let timeout = null;
      $(".calculate-price").on("keyup", function() {
        var submit_url = $(this).data('action');
        var amount = $(this).val();
        clearTimeout(timeout);
        timeout = setTimeout(function () {
          $.ajax({
            type: "POST",
            url: submit_url,
            data: "amount=" + amount,
            success: function(data) {
              addAmountToLoginUrl(amount);
            }
          });
        }, 750);
      });
      // Limit Max Lenght of Input
      $(".calculate-price").on("input", function() {
        if (this.value.length > this.maxLength) this.value = this.value.slice(0, this.maxLength);
      });
    }

    function addAmountToLoginUrl(amount) {
      var href = $(".login-link").data("href");
      $(".login-link").attr("href", href + '?amount=' + amount);
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
