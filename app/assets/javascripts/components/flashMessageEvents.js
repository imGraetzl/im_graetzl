APP.components.flashMsgEvents = (function() {

    function init() {

      function flashMsg(message) {
        if ( $("#flash .notice").text().indexOf(message) >= 0 ){
          return true;
        }
      }

      // Registration SignUp
      if (flashMsg('Super, du bist nun registriert!')){
        gtag('event', 'sign_up');
      }

      // Activate Coop & Share
      else if (flashMsg('Dein Coop & Share Angebot ist nun aktiv')){
        gtag(
          'event', 'Coop & Share :: Click :: Status Aktiv'
        );
      }

      // Deactivate Coop & Share
      else if (flashMsg('Dein Coop & Share Angebot ist nun deaktiviert')){
        gtag(
          'event', 'Coop & Share :: Click :: Status Inaktiv'
        );
      }

      // Reactivate Coop & Share
      else if (flashMsg('Dein Coop & Share Angebot wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Coop & Share :: Click :: E-Mail Aktivierungslink'
        );
      }

      // Activate RoomOffer
      else if (flashMsg('Dein Raumteiler ist nun aktiv')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Aktiv'
        );
      }

      // Deactivate RoomOffer
      else if (flashMsg('Dein Raumteiler ist nun deaktiviert')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Inaktiv'
        );
      }

      // Reactivate RoomsOffers
      else if (flashMsg('Dein Raumteiler wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Raumangebot :: Click :: E-Mail Aktivierungslink'
        );
      }

      // Warteliste RoomOffer
      else if (flashMsg('Dein Raumteiler hat nun eine Warteliste')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Warteliste'
        );
      }

      // Activate RoomDemand
      else if (flashMsg('Deine Raumsuche ist nun aktiv')){
        gtag(
          'event', 'Raumsuche :: Click :: Status Aktiv'
        );
      }

      // Deactivate RoomDemand
      else if (flashMsg('Deine Raumsuche ist nun deaktiviert')){
        gtag(
          'event', 'Raumsuche :: Click :: Status Inaktiv'
        );
      }

      // Reactivate RoomDemand
      else if (flashMsg('Deine Raumsuche wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Raumsuche :: Click :: E-Mail Aktivierungslink'
        );
      }

      // Deactivate RoomDemand
      else if (flashMsg('Der Aktivierungslink ist leider ungültig')){
        gtag(
          'event', 'Error :: Aktivierungslink ungültig'
        );
      }

      // Activate ToolDemand
      else if (flashMsg('Deine Gerätesuche ist nun aktiv')){
        gtag(
          'event', 'Gerätesuche :: Click :: Status Aktiv'
        );
      }

      // Deactivate ToolDemand
      else if (flashMsg('Deine Gerätesuche ist nun deaktiviert')){
        gtag(
          'event', 'Gerätesuche :: Click :: Status Inaktiv'
        );
      }

      // Favorite Graetzls
      else if (flashMsg('Deine Favoriten wurden gespeichert')){
        gtag(
          'event', 'User Settings :: Favorite Graetzls :: Save'
        );
      }

      // Meeting Error
      else if (flashMsg('Du hast bereits ein zukünftiges Treffen mit dem Titel')){
        gtag(
          'event', 'Error :: Meeting :: Duplicate', {
          'event_label': 'Duplicate: ' + $("#meeting_name").val()
        });
      }
    }

    return {
      init: init
    }

})();
