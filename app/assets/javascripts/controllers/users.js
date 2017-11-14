APP.controllers.users = (function() {

    function init() {
        APP.components.tabs.initTabs(".tabs-ctrl");
        APP.components.notificationSettings.init();

        if ($("section.userprofile").exists()) {
          $('.autosubmit-stream').submit();
        }
    }

    return {
        init: init
    }

})();
