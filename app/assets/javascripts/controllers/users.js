APP.controllers.users = (function() {

    function init() {
      $('.tabs-ctrl').tabslet({
            animation: true,
            deeplinking: true
        });
    }
    

// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();