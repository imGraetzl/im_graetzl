APP.components.notificatonCenter = (function() {
    const DROPDOWN_OPEN = 'jq-dropdown-open';
    var $notificationsContainer;
    var $notificationsTrigger;

    function init() {
        console.log("INIT NOTIFICATION CENTER");
        $(window).load(function() {
          $notificationsContainer = $("[data-behavior='notifications-container']");
          $notificationsTrigger = $("[data-behavior='notifications-trigger']");
          if ($notificationsContainer.length > 0) setup()
        });
    }

    function setup() {
        $notificationsTrigger.click(markAsSeen);
        update();
    }

    function update() {
        setTimeout(function() {
          if (notificationCenterOpen()) {
            console.log("CLOSED");
              update();
          } else {
              pollServer();
          }
        }, 3000);
    }

    function pollServer() {
        $.ajax({
            url: "/notifications",
            dataType: "script",
            type: "GET",
            success: function() {
                update();
                console.log("SUCCESSFULL GET DATA REQUEST")
            }
        });
    }

    function markAsSeen() {
        $.ajax({
            url: "/notifications/mark_as_seen",
            dataType: "script",
            type: "POST",
            data: {ids: currentNotificationIds()},
            success: function() {
                console.log("SUCCESSFULL MARK AS SEEN REQUEST")
            },
            error: function() {
                console.log("UNSUCCESSFULL MARK AS SEEN REQUEST")
            }
        });
    }

    function currentNotificationIds() {
        var $notificationItems = $("[data-behavior='notifications-item']");
        var notificationIds = [].map.call($notificationItems, function(obj) {
            return obj['id'].replace('notification_', '');
        });
        return JSON.stringify(notificationIds);
    }

    function notificationCenterOpen() {
        return $notificationsTrigger.hasClass(DROPDOWN_OPEN);
    }

    return {
        init: init
    }

})();
