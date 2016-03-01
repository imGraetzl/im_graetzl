APP.controllers.meetings = (function() {

    function init() {

        if($("section.meetings-overview").exists()) initMeetingsOverview();
        if($("section.meeting").exists()) initMeetingDetail();
        if($("section.create-meeting").exists()) initCreateMeeting();

    }



    function initMeetingsOverview() {
        var numBoxes = $(".cardBoxCollection:eq(0) .cardBox").length;
        var map =  APP.components.graetzlMap;
        var mapdata = $('#graetzlMapWidget').data('mapdata');

        map.init(function() {
                map.showMapGraetzl(mapdata.graetzls, {
                    style: $.extend(map.styles.rose, {
                        weight: 4,
                        fillOpacity: 0.2
                    })
                });

            }
        );
        if (numBoxes > 0) $(".cardBoxCollection:eq(0) .cardBox:nth-child(3)").after($(".cardbox-wrp"));
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
