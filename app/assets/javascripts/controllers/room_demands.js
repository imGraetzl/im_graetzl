APP.controllers.room_demands = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
    if ($("section.roomDetail").exists()) { initRoomDetail(); }
    if ($("#hide-contact-link").exists()) inithideContactLink();
  }

  function initRoomDetail() {

    // Sidebar Button Click
    $('#requestRoomBtn').on('click', function(event){
      event.preventDefault();
      var href = $(this).attr('href');
      gtag(
        'event', 'Raumsuche :: Click :: Kontaktieren', {
        'event_category': 'Raumteiler',
        'event_callback': function() {
          location.href = href;
        }
      });
    });


    $('#contact-infos-block').hide();
    $('#show-contact-link').on('click', function(event){
      event.preventDefault();
      $('#contact-infos-block').fadeIn();
      $(this).hide();
      gtag(
        'event', 'Raumsuche :: Click :: Kontaktinformationen einblenden', {
        'event_category': 'Raumteiler'
      });
    });


  }


  function inithideContactLink(){
    $('#contact-infos-block').show();
    $('#show-contact-link').hide();
  }


  function initRoomForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    $("textarea").autogrow({ onInitialize: true });

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

  }

  return {
    init: init
  }


  })();
