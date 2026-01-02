APP.controllers.contact_list_entries = (function() {

    function init() {
        if($(".form-block").exists()) initForm();
        if($(".sheboost-card-slider").exists()) initSheboostSlider();
    }

    function initForm() {
        if($("#error_explanation").exists()) {
          $('html, body').animate({
            scrollTop: $('#error_explanation').offset().top
          }, 600);
        }
    }

    function initSheboostSlider() {
        var $slider = $(".sheboost-card-slider");
        if (!$slider.length) return;

        var perPage = parseInt($slider.data("per-page"), 10) || 2;
        var entriesUrl = $slider.data("entries-url");
        var viaPath = $slider.data("via-path");
        if (!entriesUrl) return;
        var page = 1;
        var loading = false;
        var done = false;

        var responsive = [
          {
            breakpoint: 850,
            settings: {
              item: 2,
              slideMove: 2
            }
          },
          {
            breakpoint: 600,
            settings: {
              item: 1,
              slideMove: 1
            }
          }
        ];

        function currentSettings() {
          var width = $(window).width();
          var settings = { item: perPage, slideMove: perPage };
          for (var i = 0; i < responsive.length; i++) {
            if (width < responsive[i].breakpoint) {
              settings = responsive[i].settings;
            }
          }
          return settings;
        }

        function updateControls($el) {
          var $action = $el.closest('.lSSlideOuter').find('.lSAction');
          var $prev = $action.find('.lSPrev');
          var sceneIndex = $el.getCurrentSlideCount() - 1;
          $prev.toggle(sceneIndex > 0);
        }

        $slider.lightSlider({
          item: perPage,
          slideMove: perPage,
          auto: false,
          loop: false,
          controls: true,
          pager: false,
          pauseOnHover: true,
          adaptiveHeight: false,
          responsive: responsive,
          onSliderLoad: function($el) {
            updateControls($el);
          },
          onAfterSlide: function($el, scene) {
            updateControls($el);
            if (done || loading) return;
            var settings = currentSettings();
            var total = $el.getTotalSlideCount();
            var lastVisible = (scene * settings.slideMove) + settings.item;
            if (lastVisible >= total) {
              fetchNext($el);
            }
          }
        });

        function fetchNext($el) {
          loading = true;
          $.get(entriesUrl, { page: page, via_path: viaPath }, function(html) {
            if (!$.trim(html)) {
              done = true;
              return;
            }
            $el.append(html);
            $el.refresh();
            page += 1;
          }).always(function() {
            loading = false;
          });
        }

        if ($slider.children().length <= currentSettings().item) {
          fetchNext($slider);
        }
    }

    return {
      init: init
    };

})();
