APP.components.stream = (function() {

    function init() {

        inlineEditor();
        createEntry();

        $(".entryCommentForm textarea, .entryCreate textarea").autogrow();
    }


    //we use this plugin for inline edits
    //http://www.appelsiini.net/projects/jeditable
    function inlineEditor() {

        $(".stream").on("click", ".entryUserComment .btn-edit, .entryInitialContent .btn-edit", function() {

            var $parent = $(this).closest(".entryUserComment, .entryInitialContent");
            var $txt = $parent.find(".txt");
            var sendURL = $txt.attr('send-url');

            if (!$parent.attr("data-inlineEditInitialized")) {
                initInlineEdit(sendURL);
            }

            showInlineEdit();

            function initInlineEdit(url) {
                $txt.editable(url, {
                    method    : 'PUT',
                    name      : 'content',
                    indicator : 'verarbeite...',
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

            var $parent = $(this).closest(".entryUserComment, .streamElement");
            var $txt = $parent.find(".txt");
            var sendURL = $txt.attr('send-url');

            if (confirm("Beitrag wirklich löschen?")) {
                inlineDelete(sendURL)
            }

            function inlineDelete(url) {
                var commentContent = $txt.text();
                $.ajax({
                    url: url,
                    dataType: 'script',
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
                        alert("Dein Beitrag konnte nicht gelöscht werden. Bitte versuche es später nochmal");
                    }
                });
            }
        });
    }


    // tmp solution for better ux with ajax comments/posts
    function createEntry() {
        $(".stream").on("focusin focusout", ".entryCommentForm textarea, .entryCreate textarea", function(event){
            var $parent = $(this).parents(".entryCommentForm, .entryCreate");
            var buttonText = $parent.find('button').text();

            if (event.type === 'focusin') {
                $parent.addClass("is-focused");

                // temporary solution for better UX on ajax requests (only inline comments so far)               
                var $button = $parent.find('button');
                $parent
                    .on("ajax:beforeSend", function() {
                        console.log('BEFORE SEND');
                        $button.html('sendet...').prop('disabled', true);
                    })
                    .on("ajax:complete", function(event, xhr) {
                        console.log('COMPLETE');
                        if (xhr.status != 200 || !xhr.responseText) {
                            alert('Es gab ein Problem, bitte versuch es später nochmal.');
                        } else {
                            injectContent(xhr.responseText);
                            cleanup($parent.find('form.textEditor'));
                        }
                    });

            } else if (event.type === 'focusout') {
                        console.log($parent);
                if (!$(this).val().length) {
                    if(!$parent.hasClass('entryCreate')) {
                        console.log("dreck");
                        $parent.removeClass("is-focused");
                    }
                }
            }


            // inject new content in page
            function injectContent(content) {
                var inline = $parent.hasClass('entryCommentForm');
                if (inline) {
                    $parent.before(content)
                } else {
                    $('div#stream-form').after(content);
                }
            }


            function cleanup(form) {
                $parent.removeClass("is-focused");
                $parent.off("ajax:beforeSend");
                $parent.off("ajax:complete");
                $parent.removeClass("is-focused");
                $button.html(buttonText).prop('disabled', false);

                if (form.length == 0) form = $parent;

                form.trigger('reset');

                form.find('.imgCrop').remove().end();
                $("input[name$='[images_files][]']").val('');
            }
        });
    }



    return {
        init : init
    }

})();


