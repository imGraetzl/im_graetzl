APP.components.createzuckerl = (function() {


    function init() {
        console.log("ole");
        $(".input-textarea textarea").autogrow({
            onInitialize: true
        })
    }


    return {
        init: init
    }


})();
