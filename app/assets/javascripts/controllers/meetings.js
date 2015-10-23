APP.controllers.meetings = (function() {

    function init() {

        if($("section.meetings-overview").exists()) initMeetingsOverview();

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



    function initMeetingsOverview() {
        var numBoxes = $(".cardBoxCollection .cardBox").length;
        var map =  APP.components.graetzlMap;
        var mapdata = jQuery('.meetings-overview').data('mapdata');

        map.init(function() {
                map.showMapGraetzl(mapdata.graetzls, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );

        if (numBoxes > 0) $(".cardBox:nth-child(3)").after($(".cardbox-wrp"));
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();