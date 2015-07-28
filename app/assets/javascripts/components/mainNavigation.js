APP.components.mainNavigation = (function() {

    var $mobileNavTrigger,
        $mainNavHolder,
        $mobileNavHolder,
        $mobileMainNav;

    function init() {

        $mobileNavTrigger =  $('.mobileNavToggle');
        $mainNavHolder =  $(".mainNavHolder");
        $mobileNavHolder = $(".mobileNavHolder");

        enquire
            .register("screen and (max-width:" + APP.config.majorBreakpoints.large + "px)", {
                deferSetup : true,
                setup : function() {
                    createMobileNav();
                }
            });

        $(document).on("closeAllTopnav", function() {
            closeMobileNav();
        });
    }

    function createMobileNav() {
        $mainNavHolder.find(".nav-mainActions").clone().appendTo($mobileNavHolder);
        $mobileMainNav = $mobileNavHolder.find(".nav-mainActions");
        $mobileNavTrigger.on("click", function() {
            if ($mobileMainNav.hasClass("is-open")) {
                closeMobileNav();
            } else {
                openMobileNav();
            }
        });
    }

    function openMobileNav() {
        $(document).trigger('closeAllTopnav');
        $mobileNavTrigger.addClass("is-open");
        $mobileMainNav.addClass("is-open")
    }

    function closeMobileNav() {
        $mobileNavTrigger.removeClass("is-open");
        $mobileMainNav.removeClass("is-open");
    }

    return {
        init: init
    }

})();