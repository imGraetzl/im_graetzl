APP.controllers.meetings = (function() {

    function init() {

        if($("section.startpage").exists()) initMeetingsOverview();
        if($("section.meeting").exists()) initMeetingDetail();
        if($("section.create-meeting").exists()) initCreateMeeting();

    }



    function initMeetingsOverview() {
        var filter = APP.components.masonryFilterGrid;
        var map =  APP.components.graetzlMap;
        var mapdata = $('#graetzlMapWidget').data('mapdata');

        filter.init();
        map.init(function() {
                map.showMapGraetzl(mapdata.graetzls, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );
    }



    function initMeetingDetail() {
        $('.entryDescription .txt').linkify({
            target: "_blank"
        });
    }



    function initCreateMeeting() {

        APP.components.addressSearchAutocomplete();

        $(".meet-what textarea").autogrow({
            onInitialize: true
        });

        $('.datepicker').pickadate({
            formatSubmit: 'yyyy-mm-dd',
            hiddenName: true
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

        // location field
        $('input:checkbox#location').on('change', function() {
            if(!this.checked) {
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
