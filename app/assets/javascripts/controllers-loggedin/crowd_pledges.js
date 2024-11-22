APP.controllers_loggedin.crowd_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.amount-screen").exists())  {initAmountScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-pledges-page.detail-screen").exists()) {initDetailScreen();}
      else if ($(".crowd-pledges-page.change-payment-screen").exists()) {initPaymentChangeScreen();}

    }

    function initAmountScreen() {
      APP.components.tabs.setTab('step1');
      initAmount();
      $('.-crowdRewardBox').on("click", function(event) {
        const $rewardBox = $(this);
        const $morelink = $rewardBox.find(".more-link");
        const $rewardDesc = $rewardBox.find(".description");

        if ($(event.target).is("a[target='_blank']")) {
          event.stopPropagation();
          return;
        }

        $rewardBox.toggleClass('-open');
        if ($rewardBox.hasClass("-open")) {
          $morelink.text("Weniger anzeigen");
          // Set Linkify (dont work initial because of css -webkit-line-clamp)
          $rewardDesc.linkify({target: "_blank"});
        } else {
          $morelink.text("Mehr anzeigen");
          // Remove Linkify
          $rewardDesc.find("a").each(function () {
            const text = $(this).text();
            $(this).replaceWith(text);
          });
        }
      });
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');
      initAmount();

      // Change Wording of Notice Message for CrowdPledge Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Vielen Dank für Deine Registrierung') >= 0){
          $("#flash .notice").text('Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet und kannst mit deiner Crowdfunding Unterstützung fortfahren..');
        }
        else if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deiner Crowdfunding Unterstützung.');
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
      /*
      $(".calculate-price").on("focusout", function() {
        var submit_url = $(this).data('action');
        var donation_amount = $(this).val();
        $.ajax({
            type: "POST",
            url: submit_url,
            data: "donation_amount=" + donation_amount
        });
      });
      */

      // Set Amount on Input
      let timeout = null;
      $(".calculate-price").on("keyup focusout", function() {
        var submit_url = $(this).data('action');
        var donation_amount = $(this).val();
        clearTimeout(timeout);
        timeout = setTimeout(function () {
          $.ajax({
            type: "POST",
            url: submit_url,
            data: "donation_amount=" + donation_amount
          });
        }, 750);
      });
      // Limit Max Lenght of Input
      $(".calculate-price").on("input", function() {
        if (this.value.length > this.maxLength) this.value = this.value.slice(0, this.maxLength);
      });

    }

    function initDetailScreen() {
      $('.-pledge-details-toggle').on('click', function() {
        $('.-pledge-details').slideToggle();
      });
    }

    return {
      init: init
    };

})();
