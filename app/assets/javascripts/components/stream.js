
APP.components.stream = (function() {

    function init() {

        initEntryCreateForm();
        initCommentForm();
        initImgGallery();
        initInlineEditor();

    }

    function initEntryCreateForm() {

        var $parent = $('.entryCreate:not(.js-initialized)'),
            numchars = 5;

        if($parent.find('.postTitle').exists()) {
            $parent
                .addClass('js-initialized')
                .find('.postTitle')
                .on("keyup keypress", checkinput)
                .end()
                .find('textarea')
                .autogrow();
        } else {
            initSingleTextarea($parent);
        }

        function checkinput(e) {
            var code = e.keyCode || e.which;
            (code == 13) && e.preventDefault(); //disable <Enter> key to prevent sending of form
            ($(this).val().length > numchars) ? $parent.addClass("is-focused") : $parent.removeClass("is-focused");
        }

    }

    function initCommentForm() {
        $('.entryCommentForm:not(.js-initialized)').each(function() {
            var $parent = $(this);
            initSingleTextarea($parent);
        })
    }

    function initImgGallery() {
        $('.entryImgUploads:not(.js-initialized)').featherlightGallery({
            openSpeed: 300
        }).addClass('js-initialized');
    }

    function initSingleTextarea($parent, numchars) {
        numchars = numchars || 1;
        $parent
            .addClass('js-initialized')
            .find('textarea')
            .autogrow()
            .on("keyup", function(){
                ($(this).val().length > numchars) ? $parent.addClass("is-focused") : $parent.removeClass("is-focused");
            });
    }






    //we use this plugin for inline edits
    //http://www.appelsiini.net/projects/jeditable
    function initInlineEditor() {

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
    function _DONT_entryCreate() {

        $(".stream").on("focusin", ".entryCommentForm textarea, .entryCreate textarea", function(event){
            var $parent = $(this).parents(".entryCommentForm, .entryCreate");
            $parent.addClass("is-focused");

            $parent.on("ajax:complete", function(event, xhr) {
                console.log('COMPLETE');
                if (xhr.status != 200 || !xhr.responseText) {
                    alert('Es gab ein Problem, bitte versuch es später nochmal.');
                } else {
                    injectContent(xhr.responseText);
                    cleanup($parent.find('form.textEditor'));
                }
            });


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
                $parent.off("ajax:complete");

                if (form.length == 0) form = $parent;

                form.trigger('reset');

                form.find('.imgCrop').remove().end();
                $("input[name$='[images_files][]']").val('');
            }
        });
    }



    return {
        init : init,
        initEntryCreateForm : initEntryCreateForm,
        initCommentForm : initCommentForm,
        initImgGallery : initImgGallery
    }

})();


