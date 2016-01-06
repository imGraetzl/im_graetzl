APP.components.notificatonCenter = (function() {
    var $notificationsContainer;
    var $notificationsTrigger;

    function init() {
        console.log("INIT NOTIFICATION CENTER");
        $(window).load(function() {
          console.log("WINDOW FUNCTION");
          $notificationsContainer = $("[data-behavior='notifications-container']");
          $notificationsTrigger = $("[data-behavior='notifications-trigger']");
          if ($notificationsContainer.length > 0) setup()
        });
    }

    function setup() {
        console.log("CALL SETUP");
        $notificationsTrigger.click(markAsSeen);
        getInitialData();

    }

    function getInitialData() {
        $.ajax({
            url: "/notifications",
            dataType: "script",
            type: "GET",
            success: function() {
                console.log("SUCCESSFULL JS REQUEST")
            }
        });
    }

    function markAsSeen() {
      console.log("CLICK NOTIFICATIONSTRIGGER");
    }

    return {
        init: init
    }

})();
