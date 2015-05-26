APP.controllers.application = (function() {

    function init() {
        APP.components.mainNavigation.init();
        APP.components.dropDowns();

        FastClick.attach(document.body);

    }


    // ---------------------------------------------------------------------- Returns

    return {
        init: init
    }

})();