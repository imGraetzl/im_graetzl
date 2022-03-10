APP.controllers.crowd_campaigns = (function() {

    function init() {
        if ($("section.crowd_campaign").exists()) initCrowdCampaign();
        if ($("section.crowd_campaign").data('preview')) initPreviewMode();
    }

    function initPreviewMode() {
      $("#flash").hide();
      $("footer").hide();
    }

    function initCrowdCampaign() {

      APP.components.tabs.initTabs(".tabs-ctrl", "#tabs-container");
      APP.components.tabs.initPageTab();

      // Delete target param on manual tab change
      $('.tabs-ctrl a').on("click", function() {
        var urlParams = new URLSearchParams(window.location.search);
        urlParams.delete("target");
        history.replaceState(null, null, "?" + urlParams.toString()); // Replace current querystring with the new one.
      })

      // Load on Tab Change & PageLoad
      $('.tabs-ctrl').on("_after", function() {
          if ($("#tab-supporters").is(":visible")){
            $(".form-supporters").submit();
          } else if ($("#tab-comments").is(":visible")) {
            $(".form-comments").submit();
          }
      }).trigger('_after');


      $('.btn-support').on("click", function() {
        if($("#tab-info").is(":hidden")){
          APP.components.tabs.openTab('info');
        }
        $('html, body').animate({
          scrollTop: $('.-supportBox').offset().top
        }, 600);
      });

      $('.-rewardBox .trigger').on("click", function() {
        $(this).closest('.-rewardBox').toggleClass('-open');
      });

      $('#media-slider').lightSlider({
        autoWidth: true,
        slideMargin: 10,
        mode: "slide",
        cssEasing: 'ease', //'cubic-bezier(0.25, 0, 0.25, 1)',//
        easing: 'linear', //'for jquery animation',////
        speed: 500, //ms'
        auto: false,
        loop: false,
        slideEndAnimation: true,
        keyPress: false,
        controls: true,
        prevHtml: '',
        nextHtml: '',
        adaptiveHeight:false,
        pager: false,
        enableTouch:true,
        enableDrag:false,
        freeMove:true,
        swipeThreshold: 40,
      });

    }

    return {
      init: init
    };

})();
