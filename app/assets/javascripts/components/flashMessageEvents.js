APP.components.flashMessageEvents = (function() {

    function init() {

      function flashMessage(message) {
        if ( $("#flash .notice").text().indexOf(message) >= 0 ){
          return true;
        }
      }

      // Registration SignUp
      if (flashMessage('Super, du bist nun registriert!')){
        gtag('event', 'sign_up', {'event_category': 'Registration'});
      }

      // Activate Coop & Share
      else if (flashMessage('Dein Coop & Share Angebot ist nun aktiv')){
        gtag(
          'event', 'Coop & Share :: Click :: Status Aktiv', {
          'event_category': 'Coop & Share'
        });
      }

      // Deactivate Coop & Share
      else if (flashMessage('Dein Coop & Share Angebot ist nun deaktiviert')){
        gtag(
          'event', 'Coop & Share :: Click :: Status Inaktiv', {
          'event_category': 'Coop & Share'
        });
      }

      // Reactivate Coop & Share
      else if (flashMessage('Dein Coop & Share Angebot wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Coop & Share :: Click :: E-Mail Aktivierungslink', {
          'event_category': 'Coop & Share'
        });
      }

      // Activate RoomOffer
      else if (flashMessage('Dein Raumteiler ist nun aktiv')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Aktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Deactivate RoomOffer
      else if (flashMessage('Dein Raumteiler ist nun deaktiviert')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Inaktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Reactivate RoomsOffers
      else if (flashMessage('Dein Raumteiler wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Raumangebot :: Click :: E-Mail Aktivierungslink', {
          'event_category': 'Raumteiler'
        });
      }

      // Warteliste RoomOffer
      else if (flashMessage('Dein Raumteiler hat nun eine Warteliste')){
        gtag(
          'event', 'Raumangebot :: Click :: Status Warteliste', {
          'event_category': 'Raumteiler'
        });
      }

      // Activate RoomDemand
      else if (flashMessage('Deine Raumsuche ist nun aktiv')){
        gtag(
          'event', 'Raumsuche :: Click :: Status Aktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Deactivate RoomDemand
      else if (flashMessage('Deine Raumsuche ist nun deaktiviert')){
        gtag(
          'event', 'Raumsuche :: Click :: Status Inaktiv', {
          'event_category': 'Raumteiler'
        });
      }

      // Reactivate RoomDemand
      else if (flashMessage('Deine Raumsuche wurde erfolgreich verlängert!')){
        gtag(
          'event', 'Raumsuche :: Click :: E-Mail Aktivierungslink', {
          'event_category': 'Raumteiler'
        });
      }

      // Deactivate RoomDemand
      else if (flashMessage('Der Aktivierungslink ist leider ungültig')){
        gtag(
          'event', 'Raumteiler :: Click :: Aktivierungslink ungültig', {
          'event_category': 'Raumteiler'
        });
      }

      // Activate ToolDemand
      else if (flashMessage('Deine Toolsuche ist nun aktiv')){
        gtag(
          'event', 'Toolsuche :: Click :: Status Aktiv', {
          'event_category': 'Toolteiler'
        });
      }

      // Deactivate ToolDemand
      else if (flashMessage('Deine Toolsuche ist nun deaktiviert')){
        gtag(
          'event', 'Toolsuche :: Click :: Status Inaktiv', {
          'event_category': 'Toolteiler'
        });
      }

      // Favorite Graetzls
      else if (flashMessage('Deine Favoriten wurden gespeichert')){
        gtag(
          'event', 'Favorite Graetzls :: Save', {
          'event_category': 'User Settings'
        });
      }
    }

    return {
      init: init
    }

})();
