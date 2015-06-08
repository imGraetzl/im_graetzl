APP.controllers.graetzls = (function() {

    function init() {

        APP.components.imgUploadPreview();

        $(".entryCommentForm textarea, .entryCreate textarea").autogrow();

        $(".stream").on("focusin focusout", "textarea", function(event){
            var $parent = $(this).parents(".entryCommentForm, .entryCreate");
            if (event.type === 'focusin') {
                $parent.addClass("is-focused");
            } else if (event.type === 'focusout') {
                if (!$(this).val().length) {
                    $parent.removeClass("is-focused");
                }
            }
        });

    }

    return {
        init: init
    }

})();