APP.controllers.application = (function() {



    function init() {

        APP.components.mainNavigation.init();
        APP.components.stream.init();

        // test some stuff
        APP.components.notificatonCenter.init();
        console.log("AFTER INIT");

        FastClick.attach(document.body);

        window.cookieconsent_options = {
            "message":"Diese Website verwendet Cookies. Indem Sie weiter auf dieser Website navigieren, stimmen Sie unserer Verwendung von Cookies zu.",
            "dismiss":"OK!","learnMore":"Mehr Information",
            "link":"http://www.imgraetzl.at/info/datenschutz",
            "theme": false
        };



        // jQuery('.notificationsTrigger').click(function() {
        //     jQuery('#notifications_more').trigger('click');
        // });

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
