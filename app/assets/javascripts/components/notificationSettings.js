APP.components.notificationSettings = (function() {
    var WEB_URL = '/users/notification_settings/toggle_website_notification';
    var MAIL_URL = '/users/notification_settings/change_mail_notification';
    var $webToggles;
    var $mailToggles;

    function init() {
        console.log("INIT NOTIFICATION SETTINGS");
        $webToggles = $("[data-behavior='website-notification-toggle']");
        $mailToggles = $("[data-behavior='mail-notification-toggle']");
        if (($webToggles.length > 0) && ($mailToggles.length > 0)) setup();
    }

    function setup() {
        $webToggles.each(function() {
            var $toggle = $(this);
            $toggle.click(toggle_web_notification($toggle));
        });
        $mailToggles.each(function() {
            var $toggle = $(this);
            $toggle.change(change_mail_notification($toggle));
        });

    }

    function toggle_web_notification(toggle) {
        return function() {
            $.ajax({
                url: WEB_URL,
                dataType: "json",
                type: "POST",
                data: { type: toggle.data('type') },
                success: function() {
                    console.log("SUCCESSFULL TOGGLE WEBSITE NOTIFICATION REQUEST")
                },
                error: function() {
                    console.log("UNSUCCESSFULL TOGGLE WEBSITE NOTIFICATION REQUEST")
                }
            });
        }
    }

    function change_mail_notification(toggle) {
        return function() {
            $.ajax({
                url: MAIL_URL,
                dataType: "json",
                type: "POST",
                data: { type: toggle.data('type'), interval: toggle.find("option:selected")[0].value },
                success: function() {
                    console.log("SUCCESSFULL CHANGE MAIL NOTIFICATION REQUEST")
                },
                error: function() {
                    console.log("UNSUCCESSFULL CHANGE MAIL NOTIFICATION REQUEST")
                }
            });
        }
    }

    return {
        init: init
    }

})();
