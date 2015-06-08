APP.controllers.graetzls = (function() {

    function init() {

        APP.components.imgUploadPreview();

        $(".entryCommentForm textarea, .entryCreate textarea").autogrow();

        $(".entryCommentForm textarea")
            .on("focus", function () {
                var $parent = $(this).parents(".entryCommentForm");
                $parent.addClass("is-focused");
            })
            .on("blur", function () {
                var $parent = $(this).parents(".entryCommentForm");
                if (!$(this).val().length) {
                    $parent.removeClass("is-focused");
                }
            });

        $(".entryCreate textarea")
            .on("focus", function () {
                var $parent = $(this).parents(".entryCreate");
                $parent.addClass("is-focused");
            })
            .on("blur", function () {
                var $parent = $(this).parents(".entryCreate");
                if (!$(this).val().length) {
                    $parent.removeClass("is-focused");
                }
            });

    }


    return {
        init: init
    }


})();