APP.controllers.zuckerls = (function() {

    function init() {
        APP.components.createzuckerl.init();
        $('.zuckerlCollection').masonry({
            percentPosition: true
        });
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
