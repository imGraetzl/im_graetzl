APP.components.stream = (function() {

    function init() {

        initEntryCreateForm();
        initCommentForm();
        $('textarea').autoheight();

        $('.show-all-comments').on("click", function() {
          $(this).parents(".post-comments").find(".comment-container").show();
          $(this).hide();
        });

        // Edit Post Inline Form
        $(".streamElement").on('click', '.edit-post-link', function() {
          $(this).parents(".streamElement").addClass("editing");
          $('textarea').autoheight();
        }).on('click', '.cancel-edit-link', function() {
          $(this).parents(".streamElement").removeClass("editing");
        });

    }

    function initEntryCreateForm() {

        var $parent = $('.entryCreate').not('.js-initialized');

        if($parent.find('.postMessage').exists()) {
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

    function initLinkify(content) {
      if (typeof content !== "undefined") {
        content.linkify({ target: "_blank"});
      }
    }

    function initCommentForm() {
        $('.entryForm').not('.js-initialized').each(function() {
            var $parent = $(this);
            initSingleTextarea($parent);
        })
    }

    function initSingleTextarea($parent) {
        $parent
            .addClass('js-initialized')
            .find('textarea')
            .on("focusin touch", function(){
                (APP.utils.isLoggedIn() || $(this).hasClass("guest-enabled")) ? $parent.addClass("is-focused") : injectFormBlocker($parent);
            });
    }

    function injectFormBlocker($container) {
        $('.stream .formBlocker').remove();

        var url = window.location.href.split('?')[0];
        var target = $container.closest('.streamElement').attr('id');
        if (typeof target !== "undefined") {
          url = url + "?target=" + target
        }

        var $markup = $('<div class="formBlocker">' +
            '<div class="wrp">' +
            '<div>Du musst eingeloggt sein, um einen Kommentar zu verfassen.</div>' +
            '<div><a href="/users/login?redirect=' + url + '">Zum Login</a> | <a href="/users/registrierung?origin='+window.location.pathname+'">Zur Registrierung</a></div>' +
            '<span class="close"></span>' +
            '</div>' +
            '</div>');

        $container.find('textarea').prop('disabled', true);
        $container.find('textarea').blur();
        $container.append($markup);
        $markup.hide().fadeIn();
        $markup.on('click', function(e) { e.stopPropagation(); });
        $container.find('.close').on('click.hideblock', function(e) {
            $markup.remove();
            $container.find('textarea').prop('disabled', false);
        });
    }

    return {
        init : init,
        initEntryCreateForm : initEntryCreateForm,
        initCommentForm : initCommentForm,
        initLinkify: initLinkify
    }

})();
