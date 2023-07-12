APP.controllers.crowd_donation_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.choice-screen").exists())  {initChoiceScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.detail-screen").exists()) {initDetailScreen();}
    }

    function initChoiceScreen() {
      APP.components.tabs.setTab('step1');
      $('.-crowdRewardBox .left, .-crowdRewardBox .right').on("click", function() {
        $(this).closest('.-crowdRewardBox').toggleClass('-open');
      });
      $('.-crowdRewardBox .right .txtlinky a').on("click", function() {
        // Keep it open
        $(this).closest('.-crowdRewardBox').toggleClass('-open');
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

    function initDetailScreen() {
      $('.-pledge-details-toggle').on('click', function() {
        $('.-pledge-details').slideToggle();
      });
    }

    return {
      init: init
    };

})();
