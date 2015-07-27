APP.controllers.application = (function() {



    function init() {

        APP.components.mainNavigation.init();

        APP.components.mainnavDropdown('.usersettingsTrigger', '.usersettingsContainer');
        APP.components.mainnavDropdown('.notificationsTrigger', '.notificationsContainer');

        FastClick.attach(document.body);

    }


    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();