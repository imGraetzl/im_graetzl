
APP.components.stream = (function() {

    function init() {

        initEntryCreateForm();
        initCommentForm();
        initImgGallery();
        //initInlineEditor();

    }

    function initEntryCreateForm() {

        var $parent = $('.entryCreate:not(.js-initialized)');

        if($parent.find('.postTitle').exists()) {
        //$parent.find('.postMessage').autogrow();
            $parent.addClass('js-initialized')
                .find('.postTitle, .postMessage')
                .on("focusin", function() {
                    $parent.addClass("is-focused");
                })
                .on("focusout", function() {
                    if(!$('.postTitle').val().length && !$('.postMessage').val().length ) {
                        $parent.removeClass("is-focused");
                    }
                });
        } else {
            initSingleTextarea($parent);
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

    function initSingleTextarea($parent) {
        $parent
            .addClass('js-initialized')
            .find('textarea')
            .autogrow()
            .on("focusin", function(){
                $parent.addClass("is-focused");
            })
            .on("focusout", function() {
                (!$(this).val().length) && $parent.removeClass("is-focused");
            });
    }






    //we use this plugin for inline edits
    //http://www.appelsiini.net/projects/jeditable
    // function initInlineEditor() {
    //
    //     $(".stream").on("click", ".entryUserComment .btn-edit, .entryInitialContent .btn-edit", function() {
    //
    //         var $parent = $(this).closest(".entryUserComment, .entryInitialContent");
    //         var $txt = $parent.find(".txt");
    //         var sendURL = $txt.attr('send-url');
    //
    //         if (!$parent.attr("data-inlineEditInitialized")) {
    //             initInlineEdit(sendURL);
    //         }
    //
    //         showInlineEdit();
    //
    //         function initInlineEdit(url) {
    //             $txt.editable(url, {
    //                 method    : 'PUT',
    //                 name      : 'content',
    //                 indicator : 'verarbeite...',
    //                 type      : 'autogrow',
    //                 cancel    : 'Abbrechen',
    //                 submit    : 'Ändern'
    //                 //onblur    : 'ignore',
    //                 // submitdata : {
    //                 //     id: commentID //comment id, so we don't need to use a hidden field
    //                 // }
    //             });
    //             $parent.attr("data-inlineEditInitialized", true);
    //             $txt.on("focusin", "textarea" ,function() {
    //                 $parent.addClass("inlineEdit-isVisible");
    //             });
    //             $txt.on("focusout", "textarea", function() {
    //                 $parent.removeClass("inlineEdit-isVisible");
    //             });
    //         }
    //
    //         function showInlineEdit() {
    //             $txt.trigger("click");
    //         }
    //
    //     });
    //
    //     $(".stream").on("click", ".entryUserComment .btn-delete, .entryInitialContent .btn-delete", function() {
    //
    //         var $parent = $(this).closest(".entryUserComment, .streamElement");
    //         var $txt = $parent.find(".txt");
    //         var sendURL = $txt.attr('send-url');
    //
    //         if (confirm("Beitrag wirklich löschen?")) {
    //             inlineDelete(sendURL)
    //         }
    //
    //         function inlineDelete(url) {
    //             var commentContent = $txt.text();
    //             $.ajax({
    //                 url: url,
    //                 dataType: 'script',
    //                 type: 'DELETE',
    //                 beforeSend: function() {
    //                     $txt.html('löschen...');
    //                 },
    //                 success: function(data, textStatus, jqXHR) {
    //                     $parent.fadeOut('slow', function() {
    //                         $(this).remove();
    //                     });
    //                 },
    //                 error: function(jqXHR, textStatus,errorThrown) {
    //                     $txt.html(commentContent);
    //                     alert("Dein Beitrag konnte nicht gelöscht werden. Bitte versuche es später nochmal");
    //                 }
    //             });
    //         }
    //     });
    // }

    return {
        init : init,
        initEntryCreateForm : initEntryCreateForm,
        initCommentForm : initCommentForm,
        initImgGallery : initImgGallery
    }

})();
