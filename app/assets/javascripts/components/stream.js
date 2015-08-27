APP.components.stream = (function() {

    function init() {
        APP.components.imgUploadPreview();
        inlineEditor();

        $(".entryCommentForm textarea, .entryCreate textarea").autogrow();

        $(".stream").on("focusin focusout", ".entryCommentForm textarea, .entryCreate textarea", function(event){
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


    //we use this plugin for inline edits
    //http://www.appelsiini.net/projects/jeditable
    function inlineEditor() {

        $(".stream").on("click", ".entryUserComment .btn-edit, .entryInitialContent .btn-edit", function() {

            var $parent = $(this).closest(".entryUserComment, .entryInitialContent");
            var $txt = $parent.find(".txt");
            var commentID = $parent.data("commentid");
            var sendURL = "/updatecomment/"+commentID; // change URL here

            if (!$parent.attr("data-inlineEditInitialized")) {
                initInlineEdit(sendURL);
            }

            showInlineEdit();

            function initInlineEdit(url) {
                $txt.editable(url, {
                    method    : 'PUT',
                    name      : 'textareaNAME', // name of the value inside the textarea
                    type      : 'autogrow',
                    cancel    : 'Abbrechen',
                    submit    : 'Ändern',
                    //onblur    : 'ignore',
                    submitdata : {
                        id: commentID //comment id, so we don't need to use a hidden field
                    }
                });
                $parent.attr("data-inlineEditInitialized", true);
                $txt.on("focusin", "textarea" ,function() {
                    $parent.addClass("inlineEdit-isVisible");
                });
                $txt.on("focusout", "textarea", function() {
                    $parent.removeClass("inlineEdit-isVisible");
                });
            }

            function showInlineEdit() {
                $txt.trigger("click");
            }

        });
    }



    return {
        init : init
    }

})();


