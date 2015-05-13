APP.controllers.meetings = (function() {

    function init() {

        APP.components.inputTextareaMovingLabel();
        APP.components.addressSearchAutocomplete();

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
            placeholder: 'Kategorien wählen',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

        $('#meeting_remove_cover_photo:checkbox').change(function() {
            $('.upload-image img').toggle();
        });

        $('input#meeting_cover_photo').change(function() {
            if (this.files && this.files[0]) {
                var reader = new FileReader();
            
                reader.onload = function (e) {
                    $('.upload-image img').attr('src', e.target.result);
                }
                
                reader.readAsDataURL(this.files[0]);
            }
        });

        // titleImg
        $(document).on('ready page:load', function() {
            $(".titleImg").css("opacity", 1);
        })

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();