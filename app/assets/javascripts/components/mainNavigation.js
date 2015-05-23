APP.components.mainNavigation = (function() {

    var getMq = APP.utils.getMq;


    function init() {
        enquire.register(getMq("<large"), {
            deferSetup : true,
            setup : function() {
                createMobileNav();
            }
        });
    }


    function createMobileNav() {
        var $mainHolder =  $(".mainNavHolder"),
            $mobileNav = $('<div class="mobileNavHolder">');
        $mainHolder.find(".nav-mainActions, .nav-loggedOut").clone().appendTo($mobileNav);
        $mobileNav.insertAfter($mainHolder).hide();

        $(".mobileNavToggle").on("click", function() {
            ($mobileNav.is(":visible")) ? $mobileNav.hide() : $mobileNav.show();
        });
    }


    return {
        init: init
    }

})();