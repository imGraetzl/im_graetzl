APP.components.mainnavDropdown = function(trigger, container) {

    var $dropdownTrigger, $dropdownContainer, $mobileDropdownContainer, $mainNavHolder, $mobileNavHolder;

    function init() {
        $dropdownTrigger =  $(trigger);
        $dropdownContainer =  $(container);
        $mainNavHolder =  $(".mainNavHolder");
        $mobileNavHolder = $(".mobileNavHolder");

        enquire
            .register("screen and (max-width:" + APP.config.majorBreakpoints.medium + "px)", {
                deferSetup : true,
                setup : function() {
                    createMobileDropdownContainer();
                },
                match : function() {
                    bindMobileEvents();
                },
                unmatch: function() {
                    unbindMobileEvents();
                    closeMobileNotifications();
                }
            })
            .register("screen and (min-width:" + APP.config.majorBreakpoints.medium + "px)", {
                deferSetup : true,
                setup : function() {
                    $dropdownTrigger.jqDropdown('attach', container);
                },
                match : function() {
                    $dropdownTrigger.jqDropdown('enable');

                },
                unmatch: function() {
                    $dropdownTrigger.jqDropdown('disable');
                    $dropdownTrigger.jqDropdown('hide');
                }
            });

    }

    function createMobileDropdownContainer() {
        $mobileDropdownContainer = $dropdownContainer.find(".jq-dropdown-panel").clone().removeClass("jq-dropdown-panel").appendTo($mobileNavHolder);
        $(document).on("closeAllTopnav", function() {
            closeMobileNotifications();
        })
    }

    function bindMobileEvents() {
        $dropdownTrigger.on('click', function() {
            if ($mobileDropdownContainer.is(":visible")) {
                closeMobileNotifications();
            } else {
                openMobileDropdown();
            }
        })
    }

    function unbindMobileEvents() {
        $dropdownTrigger.off('click');
    }

    function openMobileDropdown() {
        $(document).trigger("closeAllTopnav");
        $dropdownTrigger.addClass("is-open");
        $mobileDropdownContainer.addClass("is-open");
    }

    function closeMobileNotifications() {
        $mobileDropdownContainer.removeClass("is-open");
        $dropdownTrigger.removeClass("is-open");
    }

    init();

};