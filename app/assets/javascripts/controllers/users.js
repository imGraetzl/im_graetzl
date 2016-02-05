APP.controllers.users = (function() {

    function init() {
        APP.components.tabs.initTabs(".tabs-ctrl");
        APP.components.notificationSettings.init();
    }

// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
