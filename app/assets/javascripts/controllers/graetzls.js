APP.controllers.graetzls = (function() {

    var map =  APP.components.graetzlMap;

    function init() {
        var mapvisible= jQuery('section.graetzls').data('mapvisible');
        map.init(function() {
                map.showMapGraetzl(mapvisible.graetzls, null, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );



        //TODO move this code in streamModule
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