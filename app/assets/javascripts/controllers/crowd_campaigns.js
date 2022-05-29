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

      $('.mob .last-supporters').lightSlider({
        item: 1,
        slideMove: 1,
        mode: "fade",
        speed: 1000,
        auto: true,
        loop: true,
        pause: 4000,
        controls: false,
        pager: false,
        enableTouch:true,
        enableDrag:false,
        pauseOnHover: true,
      });

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
          } else if ($("#tab-posts").is(":visible")) {
            $(".form-posts").submit();
          } else if ($("#tab-compose-mail").is(":visible")) {
            $(".form-compose-mail").submit();
          }
      }).trigger('_after');

      $('.-crowdRewardBox .left, .-crowdRewardBox .right').on("click", function() {
        $(this).closest('.-crowdRewardBox').toggleClass('-open');
      });

      $('.btn-support').on("click", function() {
        if($("#tab-info").is(":hidden")){
          APP.components.tabs.openTab('info');
        }
        $('html, body').animate({
          scrollTop: $('.-supportBox').offset().top
        }, 600);
      });

      $('.crowd_campaign .fundingArea .-supporters').on("click", function() {
        if($("#tab-supporters").is(":hidden")){
          APP.components.tabs.openTab('supporters');
        }
        $('html, body').animate({
          scrollTop: $('#tab-supporters').offset().top
        }, 600);
      });

      // Edit Post Inline Form
      $(".streamElement").on('click', '.edit-post-link', function() {
        $(this).parents(".streamElement").addClass("editing");
        $('textarea').autoheight();
      }).on('click', '.cancel-edit-link', function() {
        $(this).parents(".streamElement").removeClass("editing");
      });

    }

    return {
      init: init
    };

})();
