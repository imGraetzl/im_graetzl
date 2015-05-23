APP.controllers.application = (function() {

    function init() {
        APP.components.mainNavigation.init();
        APP.components.dropDowns();
    }


    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();