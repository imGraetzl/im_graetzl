APP.controllers.meetings = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();

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
        $(".titleImg").css("opacity", 1);

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

        // location field
        $('input:checkbox#location').on('change', function() {
            if(!this.checked) {
                console.log('reset location field');
                $('#meeting_location_id').val('');    
            }
            $('div#meeting-location-field').toggle();
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();