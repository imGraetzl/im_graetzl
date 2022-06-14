APP.controllers.meetings = (function() {

    function init() {
      if ($("section.meeting").exists()) {
        initMeetingDetail();
        if ($("#leafletMap").exists()) APP.components.leafletMap.init($('#leafletMap'));
      }
    }

    function initMeetingDetail() {

      // Submit Further Meetings & Hide Block if Empty
      $('.autosubmit-stream').submit();
      $(".autosubmit-stream").bind('ajax:complete', function() {
        if ($("[data-behavior=meetings-card-container]").is(':empty')){
          $(".meetingBlock").hide();
        }
      });

      if ($(".additonal").exists()) {
        $('.dateTime').lightSlider({
          item: 2,
          autoWidth: false,
          slideMove: 2, // slidemove will be 1 if loop is true
          slideMargin: 0,
          addClass: 'additionalSlider',
          mode: "slide",
          useCSS: true,
          cssEasing: 'ease', //'cubic-bezier(0.25, 0, 0.25, 1)',//
          easing: 'linear', //'for jquery animation',////
          speed: 750, //ms'
          auto: false,
          loop: false,
          slideEndAnimation: true,
          pause: 10000,
          keyPress: false,
          controls: true,
          prevHtml: '',
          nextHtml: '',
          adaptiveHeight:false,
          pager: false,
          enableTouch:true,
          enableDrag:false,
          freeMove:true,
          swipeThreshold: 40,
          responsive : [
            {
              breakpoint:APP.config.majorBreakpoints.large,
              settings: {
                item: 1,
                slideMove: 1
              }
            }
          ]
        });
      }

      var attendMeeting = new jBox('Modal', {
        addClass:'jBox',
        attach: '#attendMeeting',
        content: $('#jBoxAttendMeeting'),
        trigger: 'click',
        closeOnEsc:true,
        closeOnClick:'body',
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        onOpen: function() {
          gtag(
            'event', 'Click :: Teilnehmen', {
            'event_category': 'Meeting',
          });
        },
      });

      var meetingSettings = new jBox('Tooltip', {
        addClass:'jBox',
        attach: '#meetingSettings',
        content: $('#jBoxMeetingSettings'),
        trigger: 'click',
        closeOnClick:true,
        isolateScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });

    }

    return {
      init: init
    };

})();
