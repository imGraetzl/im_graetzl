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
          gallery: true,
          item: 1,
          loop: false,
          slideMargin: 10,
          thumbItem: 5,
          controls: false,
          onBeforeSlide: function(el) {
            var vidsrc = $('#galleryVideo').attr('src');
            $('#galleryVideo').attr('src', vidsrc);
        }
      });

    }

    return {
      init: init
    };

})();
