APP.components.notificatonCenter = (function() {
    var DROPDOWN_OPEN = '.jq-dropdown-open, .is-open',
        $notificationsContainer,
        $notificationsTrigger;

    function init() {
        console.log("INIT NOTIFICATION CENTER");
        $notificationsContainer = $("[data-behavior='notifications-container']");
        $notificationsTrigger = $("[data-behavior='notifications-trigger']");
        $(window).load(function() {
            // if ($notificationsContainer.exists()) setup();
        });
    }

    function setup() {
        $notificationsTrigger.click(handleClick);
        updateLoop();
    }

    function updateLoop() {
        setTimeout(function() {
            if (notificationCenterOpen()) {
                console.log("CLOSED");
                updateLoop();
            } else {
                pollServer(updateLoop);
            }
        }, 3000);
    }

    function handleClick() {
        if (!notificationCenterOpen()) {
            pollServer(markAsSeen)
        }
    }

    function pollServer(onSuccessCallback) {
        $.ajax({
            url: "/notifications",
            dataType: "script",
            type: "GET",
            success: function() {
                onSuccessCallback();
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
        var $notificationItems = $("[data-behavior='notification-item']");
        var notificationIds = [].map.call($notificationItems, function(obj) {
            return obj['id'].replace(/notifications_\w*_/, '');
        });
        return JSON.stringify(notificationIds);
    }

    function notificationCenterOpen() {
        return $notificationsTrigger.is(DROPDOWN_OPEN);
    }

    return {
        init: init
    }

})();
