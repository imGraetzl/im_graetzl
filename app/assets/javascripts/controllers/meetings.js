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
          //currentPagerPosition: 'middle',
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

      var ua_id = $("body").attr("data-uaid");
      var buyTicket = new jBox('Modal', {
        addClass:'jBox',
        attach: '#buyTicket',
        content: $('#jBoxBuyTicket'),
        trigger: 'click',
        closeOnEsc:true,
        closeOnClick:'body',
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        onOpen: function() {
          var meeting_id = $('#meeting_id').val();
          var page_title = 'Dein Ticket - Termin wählen - ' + document.title;
          var page_path = '/going_tos/choose_date?meeting_id='+meeting_id;
          gtag('config', ua_id, {
            'page_title': page_title,
            'page_path': page_path
          });
        }
      });

      var attendMeeting = new jBox('Modal', {
        addClass:'jBox',
        attach: '#attendMeeting',
        content: $('#jBoxAttendMeeting'),
        trigger: 'click',
        closeOnEsc:true,
        closeOnClick:'body',
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
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

      var meetingSettingsPaid = new jBox('Tooltip', {
        addClass:'jBox',
        attach: '#meetingSettingsPaid',
        content: $('#jBoxMeetingSettingsPaid'),
        trigger: 'click',
        closeOnClick:true,
        isolateScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });

      // Analytics & Form Submit!
      $('.meeting-attend-btn').on('click', function() {
        event.preventDefault();
        var form = $(this).closest("form");
        gtag(
          'event', 'Click :: Teilnehmen', {
          'event_category': 'Meeting',
          'event_callback': function() {
            form.submit();
          }
        });
      });

      // Analytics & Form Submit!
      $('.meeting-unattend-btn').on('click', function() {
        event.preventDefault();
        var form = $(this).closest("form");
        gtag(
          'event', 'Click :: Nicht mehr teilnehmen', {
          'event_category': 'Meeting',
          'event_callback': function() {
            form.submit();
          }
        });
      });

    }

    return {
      init: init
    };

})();
