APP.controllers.region_calls = (function() {

    function init() {
        if($(".form-block").exists()) initForm();
    }

    function initForm() {

        //$("textarea").autogrow({ onInitialize: true });

        if($("#error_explanation").exists()) {
          $('html, body').animate({
            scrollTop: $('#error_explanation').offset().top
          }, 600);
        }

        if($("#error_explanation").exists()) {
          $('html, body').animate({
            scrollTop: $('#error_explanation').offset().top
          }, 600);
        }

        // Toggle Region Select
        $('.region-type-switch').on('change', function() {
          if ($(this).val() == 'existing_region' & $(this).is(":checked")) {
            $('.region-select').slideDown();
          } else {
            $('.region-select').slideUp();
          }
        }).trigger('change');

        $('.callbtn').on('click', function() {
          event.preventDefault();
          $('html, body').animate({
            scrollTop: $('#call').offset().top
          }, 400);
        });


        $('.card-slider').lightSlider({
          item: 5,
          autoWidth: false,
          slideMove: 5, // slidemove will be 1 if loop is true
          slideMargin: 15,
          addClass: '',
          mode: "slide",
          useCSS: true,
          cssEasing: 'ease', //'cubic-bezier(0.25, 0, 0.25, 1)',//
          easing: 'linear', //'for jquery animation',////
          speed: 750, //ms'
          auto: false,
          loop: false,
          rtl:false,
          slideEndAnimation: true,
          pause: 15000,
          keyPress: false,
          controls: false,
          pager: true,
          prevHtml: '',
          nextHtml: '',
          adaptiveHeight:true,
          currentPagerPosition: 'middle',
          enableTouch:true,
          enableDrag:false,
          freeMove:true,
          swipeThreshold: 40,
          pauseOnHover: true,
          responsive : [
            {
              breakpoint:850,
              settings: {
                item: 3,
                slideMove: 3,
              }
            },
            {
              breakpoint:530,
              settings: {
                item: 1,
                slideMove: 1
              }
            }
          ]
        });


    }

    return {
      init: init
    };

})();
