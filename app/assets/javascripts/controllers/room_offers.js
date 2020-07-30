APP.controllers.room_offers = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
    if ($("#GAinfos").exists()) initshowContact();
    if ($("#hide-contact-link").exists()) inithideContactLink();
    if ($("section.roomDetail").exists()) { initRoomDetail(); }
    if ($("#jBoxBookRoom").exists()) initBookRoom();
    if ($(".request-price-form").exists()) initRoomOfferBookingForm();
  }

  function initRoomOfferBookingForm() {
    $('.request-price-form').find(".date-from").pickadate({
      hiddenName: true,
      min: true,
      formatSubmit: 'yyyy-mm-dd',
      format: 'ddd, dd mmm, yyyy',
      disable: [
        1,2 // if Mon and Tue is not available ...v
      ],
      onClose: function() {
        $(document.activeElement).blur();
      },
      // Insert Legend (improve ...)
      onRender: function() {
        $( "#rent_from_root .picker__box" ).append( "<div class='picker__legend'><div class='legend_not_availiable'></div><small class='legend_availiable_text'> ... Nicht verfügbar</small><div class='legend_availiable'></div><small class='legend_availiable_text'> ... Verfügbar</small></div>" );
      },

    }).off('focus').on("change", function() {
      if ($('.request-price-form .date-from').val() && $('.request-price-form .hour-from').val() && $('.request-price-form .hour-to').val()) {
        $('.request-price-form').submit();
        $('.-disabled').hide();
      }
    });
    $('.request-price-form').find(".hour-from, .hour-to").pickatime({
      interval: 60,
      format: 'HH:i',
      formatSubmit: 'HH:i',
      min: [8,00],
      max: [18,00],
      onClose: function() {
        $(document.activeElement).blur();
      },
    }).off('focus').on("change", function() {
      if ($('.request-price-form .date-from').val() && $('.request-price-form .hour-from').val() && $('.request-price-form .hour-to').val()) {
        $('.request-price-form').submit();
        $('.-disabled').hide();
      }
    });

  }

  function initRoomDetail() {

    var roomGallery = new jBox('Image', {
      addClass:'jBoxGallery',
      imageCounter:true,
      preloadFirstImage:true,
      closeOnEsc:true,
      createOnInit:true,
      animation:{open: 'zoomIn', close: 'zoomOut'},
    });

    var bookRoom = new jBox('Modal', {
      addClass:'jBox',
      attach: '#bookRoom',
      content: $('#jBoxBookRoom'),
      trigger: 'click',
      closeOnEsc:true,
      closeOnClick:'body',
      blockScroll:true,
      animation:{open: 'zoomIn', close: 'zoomOut'},
      onOpen: function() {
        // Send Click Tracking Infos
      }
    });

  }

  function initBookRoom() {
    $("#jBoxBookRoom input:radio:checked").closest('.cardBox').addClass('-checked');
    $("#jBoxBookRoom input:radio").on('click', function() {
      $("#jBoxBookRoom .cardBox").removeClass('-checked');
      $("#jBoxBookRoom input:radio:checked").closest('.cardBox').addClass('-checked');
    })
  }

  function initshowContact(){

    var roomOwner_url = $('#roomContact_url').attr('data-id');
    var roomOwner_id = $('#roomContact_id').attr('data-id');
    var roomOwner_userid = $('#roomContact_id').attr('data-user');
    var roomContact_id = $('#roomContactClick_id').attr('data-id');

    var click_track = function() {
      // Analytics Tracking
      gtag(
        'event', 'Contact Click RoomOffer: ' + roomOwner_id, {
        'event_category': 'Raumteiler',
        'event_label': 'User: ' + roomContact_id
      });

      // Mailchimp Tracking
      $.ajax({
        url : '/clicked-room',
        type : 'post',
        data : { user_id: roomOwner_userid },
        dataType: 'json',
        success: function(response) {
          //console.log(response);
        }
      });
    }

    $('#contact-infos-block').hide();
    $('#show-contact-link').on('click', function(event){
      event.preventDefault();
      $('#contact-infos-block').fadeIn();
      $(this).hide();
      click_track();
    });

    // Sidebar Button Click
    $('#room-contact-btn').on('click', function(event){
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

    $(".next-screen").on("click", function() {
      $('.tabs-ctrl').trigger('show', '#' + $(this).data("tab"));
      $('.tabs-ctrl').get(0).scrollIntoView();
    });

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

    $('select#admin-user-select').SumoSelect({
      search: true,
      csvDispCount: 5
    });
  }

  return {
    init: init,
    initshowContact : initshowContact
  }

})();
