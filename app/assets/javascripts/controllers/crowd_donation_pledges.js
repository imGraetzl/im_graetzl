APP.controllers.crowd_donation_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.choice-screen").exists())  {initChoiceScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
    }

    function initChoiceScreen() {
      APP.components.tabs.setTab('step1');
      $('.-crowdRewardBox .left, .-crowdRewardBox .right').on("click", function() {
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

    return {
      init: init
    };

})();
