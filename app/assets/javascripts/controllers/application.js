APP.controllers.application = (function() {



    function init() {

        APP.components.mainNavigation.init();
        APP.components.stream.init();

        FastClick.attach(document.body);

        jQuery('.notificationsTrigger').click(function() {
            jQuery('#notifications_more').trigger('click');
        });

       // showStoerer();

    }

    /*

    function showStoerer() {
        var $stoerer = $(".baumler-stoerer");
        if($stoerer.exists()) {
            setTimeout(function () {
                $stoerer.css('visibility', 'visible').animate({opacity: 1.0}, 1700).addClass("doAnimation");
            }, 1600);
            $stoerer.find(".close").one("click", function () {
                $stoerer.remove();
            });
        }
    }

    */





    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();