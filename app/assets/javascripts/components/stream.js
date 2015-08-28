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
            var commentID = $txt.attr('id');
            var sendURL = "/comments/"+commentID;

            if (!$parent.attr("data-inlineEditInitialized")) {
                initInlineEdit(sendURL);
            }

            showInlineEdit();

            function initInlineEdit(url) {
                $txt.editable(url, {
                    method    : 'PUT',
                    name      : 'content',
                    indicator : 'verarbeit...',
                    type      : 'autogrow',
                    cancel    : 'Abbrechen',
                    submit    : 'Ändern'
                    //onblur    : 'ignore',
                    // submitdata : {
                    //     id: commentID //comment id, so we don't need to use a hidden field
                    // }
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

        $(".stream").on("click", ".entryUserComment .btn-delete, .entryInitialContent .btn-delete", function() {

            var $parent = $(this).closest(".entryUserComment, .entryInitialContent");
            var $txt = $parent.find(".txt");
            var commentID = $txt.attr('id');
            var sendURL = "/comments/"+commentID;

            if (confirm("Kommentar wirklich löschen?")) {
                inlineDelete(sendURL)
            }

            function inlineDelete(url) {
                var commentContent = $txt.text();
                $.ajax({
                    url: url,
                    type: 'DELETE',
                    beforeSend: function() {
                        $txt.html('löschen...');
                    },
                    success: function(data, textStatus, jqXHR) {
                        $parent.fadeOut('slow', function() {
                            $(this).remove();
                        });
                    },
                    error: function(jqXHR, textStatus,errorThrown) {
                        $txt.html(commentContent);
                        alert("Dein Kommentar konnte nicht gelöscht werden. Bitte versuche es später nochmal");
                    }
                });
            }
        });
    }



    return {
        init : init
    }

})();


