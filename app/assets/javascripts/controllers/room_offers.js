APP.controllers.room_offers = (function() {

  function init() {
    if ($("section.-roomOffer").exists()) { initRoomDetail(); }
    if ($(".request-price-form").exists()) initRoomOfferBookingForm();
  }

  function initRoomOfferBookingForm() {
    var dateInput = $('.request-price-form .rent-date');
    var days = dateInput.data("days");
    var disabledDays = [true].concat(days);

    $('.request-price-form .rent-date').pickadate({
      hiddenName: true,
      min: true,
      formatSubmit: 'yyyy-mm-dd',
      format: 'ddd, dd mmm, yyyy',
      disable: disabledDays,
      onClose: function() {
        $(document.activeElement).blur();
      },
      // Insert Legend (improve ...)
      onRender: function() {
        $(".request-price-form .picker__box").append( "<div class='picker__legend'><div class='legend_not_availiable'></div><small class='legend_text'> ... an diesen Tagen nicht verfügbar</small></div>" );
        $(".request-price-form .picker__box .picker__header").append( "<div class='picker__header_info'><small class='legend_headline'>Wann möchtest du anmieten?</small><small class='legend_text'>(Du kannst im nächsten Schritt auch noch weitere Tage hinzufügen)</small></div>" );
      },
      onOpen: function() {
        $(".sticky-btns").addClass('hide');
      },
      onClose: function() {
        $(".sticky-btns").removeClass('hide');
      }
    });

    $('.request-price-form .rent-date').on("change", function() {
      $('.request-price-form .hour-input').attr("disabled", !$(this).val());
      if ($(this).val()) {$('.request-price-form .input-select').removeClass('disabled')}
    });

    $('.request-price-form').find(".rent-date, .hour-from").on("change", function() {
      var form = $(this).parents(".request-price-form");
      var hoursUrl = form.data('hours-url');
      var currentDate = form.find(".rent-date").pickadate('picker').get('select', 'yyyy-mm-dd');
      var hourFrom = form.find(".hour-from").val();

      $.get(hoursUrl, {rent_date: currentDate, hour_from: hourFrom}, function(data) {
        form.find(".hour-from option").not(':empty').each(function(i, o) {
          var hour = +$(o).val();
          $(o).attr("disabled", data.from.indexOf(hour) == -1);
        });
        form.find(".hour-to option").not(':empty').each(function(i, o) {
          var hour = +$(o).val();
          $(o).attr("disabled", data.to.indexOf(hour) == -1);
        });
      });
    });

    $('.request-price-form').on("change", '.hour-input', function() {
      if ($('.hour-from').val() > 0 && $('.hour-to').val() > 0) {
        $(this).parents(".request-price-form").submit();
        // Analytics Tracking
        gtag(
          'event', 'Buchungsbox :: Raumteiler :: Auswahl Zeitraum'
        );
      }
    });

    $(".request-price-form").on("ajax:complete", function() {
      new jBox('Tooltip', {
        attach: '.tooltip-trigger',
        trigger: 'click',
        closeOnClick: true,
        closeOnMouseleave: true,
      });
    });

    $('.btn-book').on("click", function() {
      $('#booking-box').addClass('sticky-overlay');
      $('#sticky-overlay-bg').show();
      unscroll();
      gtag(
        'event', 'Buchungsbox :: Raumteiler :: Open Mobile Modal'
      );
    });

    $('#booking-box .close-ico, #sticky-overlay').on("click", function() {
      $('#booking-box').removeClass('sticky-overlay');
      $('#sticky-overlay-bg').hide();
      unscroll.reset();
    });



  }

  function initRoomDetail() {
    APP.controllers.application.initShowContact();
    APP.controllers.application.initMessengerButton();

    if ($("#leafletMap").exists()) APP.components.leafletMap.init($('#leafletMap'));

    // Submit Further Rooms & Hide Block if Empty
    $('.autosubmit-stream').submit();
    $(".autosubmit-stream").bind('ajax:complete', function() {
      if ($("[data-behavior=rooms-card-container]").is(':empty')){
        $(".furtherRoomBlock").hide();
      }
    });

  }

  return {
    init: init
  }

})();
