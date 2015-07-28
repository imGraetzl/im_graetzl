APP.controllers.application = (function() {



    function init() {

        APP.components.mainNavigation.init();

        APP.components.mainnavDropdown('.usersettingsTrigger', '.usersettingsContainer');
        APP.components.mainnavDropdown('.notificationsTrigger', '.notificationsContainer');

        FastClick.attach(document.body);

        jQuery('.notificationsTrigger').click(function() {
            jQuery.post("/users/notification_settings/mark_as_seen").
                done(function(response) {
                    jQuery('#notificationsCount').hide();
                });
        });

    }


    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();