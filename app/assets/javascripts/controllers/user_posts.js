APP.controllers.user_posts = (function() {

    function init() {
        $(".form-block textarea").autogrow({ onInitialize: true });
    }

    return {
        init: init
    }

})();
