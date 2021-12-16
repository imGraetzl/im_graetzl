APP.controllers.going_tos = (function() {

    function init() {
      if ($(".going-to-page.login-screen").exists()) {
        initLoginScreen();
      }
    }

    function initLoginScreen() {
      // Change Wording of Notice Message for Ticket Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          // Modifiy Message for Ticket Registrations
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deinem Ticket-Kauf.');
        }
      }
    }

    return {
      init: init
    };

})();
