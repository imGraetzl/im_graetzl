APP.controllers.crowd_donation_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.choice-screen").exists())  {initChoiceScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.detail-screen").exists()) {initDetailScreen();}
    }

    function initChoiceScreen() {
      APP.components.tabs.setTab('step1');
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
