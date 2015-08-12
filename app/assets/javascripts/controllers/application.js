APP.controllers.application = (function() {



    function init() {

        APP.components.mainNavigation.init();



        Turbolinks.enableProgressBar();

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