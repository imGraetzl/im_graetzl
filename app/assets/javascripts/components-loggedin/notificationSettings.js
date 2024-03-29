APP.components.notificationSettings = (function() {
    var WEB_URL = '/users/notification_settings/toggle_website_notification',
        MAIL_URL = '/users/notification_settings/change_mail_notification',
        $webToggles,
        $mailToggles;

    function init() {
        $webToggles = $("[data-behavior='website-notification-toggle']");
        $mailToggles = $("[data-behavior='mail-notification-toggle']");
        if (($webToggles.exists()) && ($mailToggles.exists())) setup();

        // Get Target for Mandrill Linking
        $(document).ready(function() {
          initTarget();
        });
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
            });
        }
    }

    function initTarget() {
      var target = APP.controllers.application.getUrlVars()["target"];
      if (typeof target !== 'undefined') {
        var tabLink = $('a[href="#'+target+'"]');
        tabLink.click();
      }
    }

    return {
        init: init
    }

})();
