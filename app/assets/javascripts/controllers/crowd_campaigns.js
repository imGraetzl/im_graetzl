APP.controllers.crowd_campaigns = (function() {

    function init() {
        if ($("section.crowd_campaign").exists()) initCrowdCampaign();
        if ($("section.crowd_campaign").data('preview')) initPreviewMode();
    }

    function initPreviewMode() {
      //$("header").hide();
      $("footer").hide();
    }

    function initCrowdCampaign() {

    }

    return {
      init: init
    };

})();
