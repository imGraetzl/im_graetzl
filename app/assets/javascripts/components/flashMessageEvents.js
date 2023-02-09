APP.components.flashMsgEvents = (function() {

    function init() {

      function flashMsg(message) {
        if ( $("#flash .notice").text().indexOf(message) >= 0 ){
          return true;
        }
      }

      // Registration SignUp
      if (flashMsg('Super, du bist nun registriert!')){
        gtag('event', 'sign_up', {'event_category': 'Registration'});
      }

      // Activate Coop & Share
      else if (flashMsg('Dein Coop & Share Angebot ist nun aktiv')){
        gtag(
          'event', 'Coop & Share :: Click :: Status Aktiv', {
          'event_category': 'Coop & Share'
        });
      }

      // Deactivate Coop & Share
      else if (flashMsg('Dein Coop & Share Angebot ist nun deaktiviert')){
        gtag(
          'event', 'Coop & Share :: Click :: Status Inaktiv', {
          'event_category': 'Coop & Share'
        });
      }

      // Reactivate Coop & Share
      else if (flashMsg('Dein Coop & Share Angebot wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Coop & Share :: Click :: E-Mail Aktivierungslink', {
          'event_category': 'Coop & Share'
        });
      }

      // Activate RoomOffer
      else if (flashMsg('Dein Raumteiler ist nun aktiv')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Aktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Deactivate RoomOffer
      else if (flashMsg('Dein Raumteiler ist nun deaktiviert')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Inaktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Reactivate RoomsOffers
      else if (flashMsg('Dein Raumteiler wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Raumangebot :: Click :: E-Mail Aktivierungslink', {
          'event_category': 'Raumteiler'
        });
      }

      // Warteliste RoomOffer
      else if (flashMsg('Dein Raumteiler hat nun eine Warteliste')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Warteliste', {
          'event_category': 'Raumteiler'
        });
      }

      // Activate RoomDemand
      else if (flashMsg('Deine Raumsuche ist nun aktiv')){
        gtag(
          'event', 'Raumsuche :: Click :: Status Aktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Deactivate RoomDemand
      else if (flashMsg('Deine Raumsuche ist nun deaktiviert')){
        gtag(
          'event', 'Raumsuche :: Click :: Status Inaktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Reactivate RoomDemand
      else if (flashMsg('Deine Raumsuche wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Raumsuche :: Click :: E-Mail Aktivierungslink', {
          'event_category': 'Raumteiler'
        });
      }

      // Deactivate RoomDemand
      else if (flashMsg('Der Aktivierungslink ist leider ungültig')){
        gtag(
          'event', 'Raumteiler :: Click :: Aktivierungslink ungültig', {
          'event_category': 'Raumteiler'
        });
      }

      // Activate ToolDemand
      else if (flashMsg('Deine Gerätesuche ist nun aktiv')){
        gtag(
          'event', 'Gerätesuche :: Click :: Status Aktiv', {
          'event_category': 'Geräteteiler'
        });
      }

      // Deactivate ToolDemand
      else if (flashMsg('Deine Gerätesuche ist nun deaktiviert')){
        gtag(
          'event', 'Gerätesuche :: Click :: Status Inaktiv', {
          'event_category': 'Geräteteiler'
        });
      }

      // Favorite Graetzls
      else if (flashMsg('Deine Favoriten wurden gespeichert')){
        gtag(
          'event', 'Favorite Graetzls :: Save', {
          'event_category': 'User Settings'
        });
      }

      // Favorite Graetzls
      else if (flashMsg('Du hast bereits ein zukünftiges Treffen mit dem Titel')){
        gtag(
          'event', 'Meeting', {
          'event_category': 'Error',
          'event_label': 'Duplicate: ' + $("#meeting_name").val()
        });
      }
    }

    return {
      init: init
    }

})();
