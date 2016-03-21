APP.components.stream = (function() {

    function init() {

        initEntryCreateForm();
        initCommentForm();
        initImgGallery();

    }

    function initEntryCreateForm() {

        var $parent = $('.entryCreate').not('.js-initialized');

        if($parent.find('.postTitle').exists()) {
            $parent.find('.postMessage').autogrow();
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
        $('.entryCommentForm').not('.js-initialized').each(function() {
            var $parent = $(this);
            initSingleTextarea($parent);
        })
    }

    function initImgGallery() {
        $('.entryCreate').not('.js-initialized').featherlightGallery({
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

    return {
        init : init,
        initEntryCreateForm : initEntryCreateForm,
        initCommentForm : initCommentForm,
        initImgGallery : initImgGallery
    }

})();
