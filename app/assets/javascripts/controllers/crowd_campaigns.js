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

      $('.btn-support').on("click", function() {
        $('html, body').animate({
          scrollTop: $('.-supportBox').offset().top
        }, 600);
      });

      $('.-rewardBox .trigger').on("click", function() {
        $(this).closest('.-rewardBox').toggleClass('-open');
      });

      $('#media-slider').lightSlider({
        autoWidth: true,
        slideMargin: 5,
        mode: "slide",
        cssEasing: 'ease', //'cubic-bezier(0.25, 0, 0.25, 1)',//
        easing: 'linear', //'for jquery animation',////
        speed: 750, //ms'
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
