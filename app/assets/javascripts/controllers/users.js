APP.controllers.users = (function() {

    function init() {
        APP.components.tabs.initTabs(".tabs-ctrl");

        $('.toPersonal').on('click', function() {
            $('.tabs-nav [href=#tab-1]').trigger('click');
        });

        init_notification_toggles();
    }

    function init_notification_toggles() {
      $("[data-behavior='website-notification-toggle']").each(function() {
          var $toggle = $(this);
          $toggle.click(function() {
              toggle_website_notification($toggle);
          });
      });
      $("[data-behavior='mail-notification-toggle']").each(function() {
          var $toggle = $(this);
          $toggle.change(function() {
              change_mail_notification($toggle);
          });
      });
    }

    function toggle_website_notification(toggle) {
        $.ajax({
            url: "/users/notification_settings/toggle_website_notification",
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

    function change_mail_notification(toggle) {
        $.ajax({
            url: "/users/notification_settings/change_mail_notification",
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


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
