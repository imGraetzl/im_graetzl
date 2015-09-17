APP.controllers.zuckerls = (function() {

    function init() {
        $('.zuckerlCollection').masonry({
            percentPosition: true
        });
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();