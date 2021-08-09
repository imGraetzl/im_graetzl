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

    // Reactivate Raumteiler
    if ( $("#flash .notice").text().indexOf('Dein Raumteiler wurde erfolgreich verlängert!') >= 0 ){
      gtag(
        'event', 'Raumsuche :: Click :: E-Mail Aktivierungslink', {
        'event_category': 'Raumteiler'
      });
    }

    // Activate Raumteiler
    if ( $("#flash .notice").text().indexOf('Deine Raumsuche ist nun aktiv') >= 0 ){
      gtag(
        'event', 'Raumsuche :: Click :: Status Aktiv', {
        'event_category': 'Raumteiler'
      });
    }

    // Deactivate Raumteiler
    if ( $("#flash .notice").text().indexOf('Dein Raumsuche ist nun deaktiviert') >= 0 ){
      gtag(
        'event', 'Raumsuche :: Click :: Status Inaktiv', {
        'event_category': 'Raumteiler'
      });
    }


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
