APP.controllers.application = (function() {

    function init() {
        APP.components.mainNavigation.init();
        APP.components.dropDowns();

        FastClick.attach(document.body);
        jQuery('#notificationCenterDropDown').click(function() {

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