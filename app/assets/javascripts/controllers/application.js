APP.controllers.application = (function() {



    function init() {

        APP.components.mainNavigation.init();

        APP.components.mainnavDropdown('.usersettingsTrigger', '.usersettingsContainer');
        APP.components.mainnavDropdown('.notificationsTrigger', '.notificationsContainer');

        FastClick.attach(document.body);

        jQuery('.notificationsTrigger').click(function() {
            jQuery('#notifications_more').trigger('click');
        });

    }


    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();