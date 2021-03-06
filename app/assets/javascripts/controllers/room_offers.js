APP.controllers.room_offers = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
    if ($("#GAinfos").exists()) initshowContact();
    if ($("#hide-contact-link").exists()) inithideContactLink();
    if ($("section.roomDetail").exists()) { initRoomDetail(); }
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
      }
    });

    $('.request-price-form .rent-date').on("change", function() {
      $('.request-price-form .hour-input').attr("disabled", !$(this).val());
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
          'event', 'Raumangebot :: Kurzzeitmiete Buchungsbox', {
          'event_category': 'Raumteiler',
          'event_label': 'Auswahl :: Zeitraum'
        });
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

  }

  function initRoomDetail() {

    // Sidebar Button Click
    $('#requestRoomBtn').on('click', function(event){
      event.preventDefault();
      var href = $(this).attr('href');
      gtag(
        'event', 'Raumangebot :: Click :: Allgemeine Anfrage stellen', {
        'event_category': 'Raumteiler',
        'event_callback': function() {
          location.href = href;
        }
      });
    });

    // Reactivate Raumteiler
    if ( $("#flash .notice").text().indexOf('Dein Raumteiler wurde erfolgreich verlängert!') >= 0 ){
      gtag(
        'event', 'Raumangebot :: Click :: E-Mail Aktivierungslink', {
        'event_category': 'Raumteiler'
      });
    }

    // Activate Raumteiler
    if ( $("#flash .notice").text().indexOf('Dein Raumteiler ist nun aktiv') >= 0 ){
      gtag(
        'event', 'Raumangebot :: Click :: Status Aktiv', {
        'event_category': 'Raumteiler'
      });
    }

    // Deactivate Raumteiler
    if ( $("#flash .notice").text().indexOf('Dein Raumteiler ist nun deaktiviert') >= 0 ){
      gtag(
        'event', 'Raumangebot :: Click :: Status Inaktiv', {
        'event_category': 'Raumteiler'
      });
    }

    // Warteliste Raumteiler
    if ( $("#flash .notice").text().indexOf('Deine Raumteiler hat nun eine Warteliste') >= 0 ){
      gtag(
        'event', 'Raumangebot :: Click :: Status Warteliste', {
        'event_category': 'Raumteiler'
      });
    }

  }

  function initshowContact(){

    var roomOwner_url = $('#roomContact_url').attr('data-id');
    var roomOwner_id = $('#roomContact_id').attr('data-id');
    var roomOwner_userid = $('#roomContact_id').attr('data-user');
    var roomContact_id = $('#roomContactClick_id').attr('data-id');

    var click_track = function() {
      // Analytics Tracking
      gtag(
        'event', 'Raumangebot :: Click :: Kontaktinformationen einblenden', {
        'event_category': 'Raumteiler',
        'event_label': 'User: ' + roomContact_id
      });
    }

    $('#contact-infos-block').hide();
    $('#show-contact-link').on('click', function(event){
      event.preventDefault();
      $('#contact-infos-block').fadeIn();
      $(this).hide();
      click_track();
    });

  }

  function inithideContactLink(){
    $('#contact-infos-block').show();
    $('#show-contact-link').hide();
  }


  function initRoomForm() {
    APP.components.tabs.initTabs(".tabs-ctrl");
    APP.components.addressSearchAutocomplete();
    APP.components.formValidation.init();
    APP.components.search.userAutocomplete();

    $(".next-screen, .prev-screen").on("click", function() {
      $('.tabs-ctrl').trigger('show', '#' + $(this).data("tab"));
      $('.tabs-ctrl').get(0).scrollIntoView();
    });

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

    $(".availability-select").on("change", function() {
      var day = $(this).data("weekday");
      if ($(this).val() == "0") {
        $(".availability-input-" + day).prop("disabled", true);
      } else {
        $(".availability-input-" + day).removeProp("disabled");
      }
    }).change();

    // Slot Fields Toogle
    var slotsSection = null;
    $('.slot-radios .rental-toggle-input').on('change', function() {
      var rentalEnabled = $('.slot-radios .rental-toggle-input:checked').val() == 'true';
      if (rentalEnabled && slotsSection) {
        $('#slot-fields').replaceWith(slotsSection);
        $('#slot-fields').hide().slideDown();
        slotsSection = null;
      } else if (!rentalEnabled && !slotsSection){
        slotsSection = $('#slot-fields').clone();
        $('#slot-fields').empty();
      }
    }).change();


    $(".room-categories input").on("change", function() {
      maxCategories(); // init on Change
    });

    maxCategories(); // init on Load

  }

  function maxCategories() {
    if ($(".room-categories input:checked").length >= 5) {
      $(".room-categories input:not(:checked)").each(function() {
        $(this).prop("disabled", true);
        $(this).parents(".input-checkbox").addClass("disabled");
      });
    } else {
      $(".room-categories input").prop("disabled", false);
      $(".room-categories .input-checkbox").removeClass("disabled");
    }
  }

  return {
    init: init,
    initshowContact : initshowContact
  }

})();
