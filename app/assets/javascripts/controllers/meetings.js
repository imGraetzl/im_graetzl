APP.controllers.meetings = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();
        APP.components.imgUploadPreview();

        $(".meet-what textarea").autogrow();

        $('.datepicker').pickadate({
            formatSubmit: 'yyyy-mm-dd',
            hiddenSuffix: ''
        });

        $('.timepicker').pickatime({
            interval: 15,
            format: 'HH:i',
            formatSubmit: 'HH:i',
            hiddenSuffix: ''
        });

        $('select.categories').SumoSelect({
            placeholder: 'Ordne dein Treffen einen oder mehreren Themen zu',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

        // titleImg
        $(document).on('ready page:load', function() {
            $(".titleImg").css("opacity", 1);
        });

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

        // refile
        $(document).on("upload:start", "form", function(e) {
            console.log('Start upload');
          $(this).find("input[type=submit]").attr("disabled", true)
        });

        $(document).on("upload:complete", "form", function(e) {
          if(!$(this).find("input.uploading").length) {
            console.log('upload complete');
            $(this).find("input[type=submit]").removeAttr("disabled")
          }
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();