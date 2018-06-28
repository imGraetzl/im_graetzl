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

        $('[data-behavior=createTrigger]').on('click', function(){
          var group_id = $(this).attr("data-group");
          $(this).jqDropdown('attach', '[data-behavior=createContainer-'+group_id+']');
        });

    }

    return {
        init: init
    }

})();
