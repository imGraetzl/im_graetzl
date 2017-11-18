APP.controllers.users = (function() {

    function init() {
        APP.components.tabs.initTabs(".tabs-ctrl");
        APP.components.notificationSettings.init();

        if ($("section.userprofile").exists()) {
          $('.autosubmit-stream').submit();
        }
        if ($("section.rooms").exists()) {
          APP.components.cardBox.moveActionCard3rd();
        }
    }

    return {
        init: init
    }

})();
