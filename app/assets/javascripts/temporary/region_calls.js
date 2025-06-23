APP.controllers.region_calls = (function() {

    function init() {
        if($(".form-block").exists()) initForm();
    }

    function initForm() {

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
          slideMove: 5, // slidemove will be 1 if loop is true
          auto: false,
          pause: 15000,
          controls: false,
          pager: true,
          adaptiveHeight:true,
          currentPagerPosition: 'middle',
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
