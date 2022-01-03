APP.controllers.tool_rentals = (function() {

    function init() {
      if ($(".tool-rental-page.login-screen").exists()) {
        initLoginScreen();
      }
    }

    function initLoginScreen() {
      // Change Wording of Notice Message for Toolteiler Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          // Modifiy Message for Toolteiler Registrations
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deiner Toolteiler Anfrage.');
        }
      }
    }

    return {
      init: init
    };

})();
