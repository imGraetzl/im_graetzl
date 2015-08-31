APP.components.stream = (function() {

    function init() {
        APP.components.imgUploadPreview();
        inlineEditor();

        $(".entryCommentForm textarea, .entryCreate textarea").autogrow();

        $(".stream").on("focusin focusout", ".entryCommentForm textarea, .entryCreate textarea", function(event){
            var $parent = $(this).parents(".entryCommentForm, .entryCreate");
            var buttonText = $parent.find('button').text();
            
            if (event.type === 'focusin') {
                $parent.addClass("is-focused");

                // temporary solution for better UX on ajax requests (only inline comments so far)
                if ($parent.hasClass('entryCommentForm')) {                    
                    var $button = $parent.find('button');
                    var buttonText = $button.text();
                    $parent
                        .on("ajax:beforeSend", function() {
                            $button.html('sendet...');
                            //$button.prop('disabled', true);
                        })
                        .on("ajax:success", function(event, data, status, xhr) {
                            console.log('call ajax success');
                            console.log(data);
                            $parent.before(data);
                            // reset form:
                            // console.log('hello hello');
                            // console.log(data);
                            // console.log(xhr.responseText);
                        })
                        .on("ajax:error", function(event, xhr, status, error) {
                            $parent.replaceWith("<em>Es gab ein Problem, bitte versuch es später nochmal.</em>");
                        })
                        .on("ajax:complete", function(xhr, status) {
                            $button.html(buttonText);
                            $parent.trigger('reset');
                            $parent.removeClass("is-focused");
                            $parent.off("ajax:beforeSend");
                            $parent.off("ajax:error");
                            $parent.off("ajax:success");
                            $parent.off("ajax:complete");
                        });
                } else {
                    console.log('IN ELSE NOW');                   
                    var $form = $parent.find('form.textEditor');
                    console.log($form);
                    $parent
                        .on("ajax:beforeSend", function() {
                            console.log('BEFORE SEND');
                        })
                        .on("ajax:complete", function(event, xhr) {
                            // console.log(status.status);
                            // console.log(status.status != 200);
                            // console.log(status.status != '200');
                            console.log('COMPLETE');
                            // due to problems with jquery and parsing files...
                            // use complete event an manually check for errors:
                            if (xhr.status != 200 || !xhr.responseText) {
                                alert('Es gab ein Problem, bitte versuch es später nochmal.');
                            } else {
                                console.log(xhr);
                                $('div#stream-comment-form').after(xhr.responseText);
                                $form.trigger('reset');
                                $form.find('[name="comment[images_files][]"]').val('');
                                $parent.removeClass("is-focused");
                                $parent.off("ajax:beforeSend");
                                $parent.off("ajax:error");
                                $parent.off("ajax:success");
                                $parent.off("ajax:complete");
                            }
                            // $button.html(buttonText);
                            // $parent.trigger('reset');
                            // $parent.removeClass("is-focused");
                            // $parent.off("ajax:beforeSend");
                            // $parent.off("ajax:error");
                            // $parent.off("ajax:success");
                            // $parent.off("ajax:complete");
                        });
                }


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


