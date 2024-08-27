APP.controllers.crowd_campaigns = (function() {

    function init() {
        if ($("section.startcampaign").exists()) initCrowdCampaignStart();
        if ($("section.crowd_campaign").exists()) initCrowdCampaign();
        if ($("section.crowd_campaign").data('preview')) initPreviewMode();
    }

    function initCrowdCampaignStart() {
      var _href = $("#startproject").attr("href");
      $(".call-cb input").on("change", function() {
        if ($(".call-cb input:checked").length >= 1) {
          $("#startproject").attr("href", _href + '?crowdfunding_call=true');
        } else {
          $("#startproject").attr("href", _href);
        }
      }).change();


      if ($("#card-slider").exists()) {
        $('#card-slider').lightSlider({
          item: 2,
          slideMove: 2, // slidemove will be 1 if loop is true
          auto: false,
          loop: false,
          controls: false,
          pager: true,
          pauseOnHover: true,
          adaptiveHeight:false,
          responsive : [
            {
              breakpoint:850,
              settings: {
                item: 2,
                slideMove: 2,
              }
            },
            {
              breakpoint:600,
              settings: {
                item: 1,
                slideMove: 1
              }
            }
          ]
        });
      }


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

      $('.-crowdRewardBox .right .txtlinky a').on("click", function() {
        // Keep it open
        $(this).closest('.-crowdRewardBox').toggleClass('-open');
      });

      $('.btn-support').on("click", function() {
        if($("#tab-info").is(":hidden")){
          APP.components.tabs.openTab('info');
        }
        $('.mob .-toggable').removeClass('-open'); // Close Blocks on Mobile
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
