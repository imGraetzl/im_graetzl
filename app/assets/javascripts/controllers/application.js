APP.controllers.application = (function() {

    var getMq = APP.utils.getMq;


    // ---------------------------------------------------------------------- Boilerplate Functions

    function init() {
        breakPointEvents();

        $(".dropDownToggle").on("click", function() {
            var $container = $(this).next();
            ($container.is(":visible")) ? $container.hide() :  $container.show();
        });

    }

    function breakPointEvents() {

        enquire.register(getMq("<large"), {
            deferSetup : true,
            setup : function() {
                createMobileNav();
            }
        });

    }


    // ---------------------------------------------------------------------- Specific Functions

    function createMobileNav() {
        var $mainHolder =  $(".mainNavHolder"),
            $mobileNav = $('<div class="mobileNavHolder">');
        $mainHolder.find(".nav-mainActions, .nav-loggedOut").clone().appendTo($mobileNav);
        $mobileNav.insertAfter($mainHolder).hide();

        $(".mobileNavToggle").on("click", function() {
            ($mobileNav.is(":visible")) ? $mobileNav.hide() : $mobileNav.show();
        });

    }


    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();