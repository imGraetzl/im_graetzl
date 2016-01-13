APP.controllers.users = (function() {

    function init() {
        APP.components.tabs.initTabs(".tabs-ctrl");

        $('.toPersonal').on('click', function() {
            $('.tabs-nav [href=#tab-1]').trigger('click');
        });

        // notification settings
        var notfication_types = [
            "Notifications::NewMeeting",
            "Notifications::NewPost",
            "Notifications::AlsoCommentedPost",
            "Notifications::AttendeeInUsersMeeting",
            "Notifications::MeetingUpdated",
            "Notifications::CommentInUsersMeeting",
            "Notifications::NewWallComment",
            "Notifications::MeetingCancelled"
        ];
        jQuery.each(notfication_types, function(index, notification_type) {
            $('#toggle_' + notification_type).click(function() {
                jQuery.post("/users/notification_settings/toggle_website_notification", {
                    type: notification_type }).
                    done(function(response) {
                    })
                    .fail(function() {
                        alert("Etwas ist schief gegangen!");
                    });
            });

            $('#mail_notification_settings_' + notification_type).change(function() {
                jQuery.post("/users/notification_settings/change_mail_notification", {
                    type: notification_type, interval: $(this).find("option:selected")[0].value }).
                    done(function(response) {
                    })
                    .fail(function() {
                        alert("Etwas ist schief gegangen!");
                    });
            });
        });
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
