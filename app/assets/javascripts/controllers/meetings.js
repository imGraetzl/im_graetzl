APP.controllers.meetings = (function() {

    function init() {
      if ($("section.meeting").exists()) {
        initMeetingDetail();
        if ($("#leafletMap").exists()) APP.components.leafletMap.init($('#leafletMap'));
      }

      if ($("section.create-meeting").exists()) {
        initCreateMeeting();
        APP.components.search.userAutocomplete();
      }

      if ($("section.meetings-compose-mail").exists()) {
        initComposeMailMeeting();
      }

    }

    function initComposeMailMeeting() {

      $('select#mail-user-select').SumoSelect({
        search: true,
        searchText: 'Suche nach User.',
        placeholder: 'User auswählen',
        csvDispCount: 2,
        captionFormat: '{0} Treffenmitglieder',
        captionFormatAllSelected: 'Alle Treffenmitglieder',
        selectAll: true,
        isClickAwayOk: true,
        locale: ['OK', 'Abbrechen', 'Alle auswählen']
      });

      // Highlight Users on single Click Options
      $('.select_users .opt').on('click', function(){
        var user_index = $(this).index();
        if ($(this).hasClass('selected')){
          $('.meetings-compose-mail .members a').eq(user_index).find('.img-round').addClass('active');
        } else {
          $('.meetings-compose-mail .members a').eq(user_index).find('.img-round').removeClass('active');
        }
      });

    }

    function initMeetingDetail() {

      // Submit Further Meetings & Hide Block if Empty
      $('.autosubmit-stream').submit();
      $(".autosubmit-stream").bind('ajax:complete', function() {
        if ($("[data-behavior=meetings-card-container]").is(':empty')){
          $(".meetingBlock").hide();
        }
      });

      $('.entryDescription .bbcode').linkify({
        target: "_blank"
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
          gtag('config', window.imgraetzl.uaid, {
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

      // Analytics
      $('.meeting-attend-btn').on('click', function() {
        gtag(
          'event', 'Click :: Teilnehmen', {
          'event_category': 'Meeting'
        });
      });

      $('.meeting-unattend-btn').on('click', function() {
        gtag(
          'event', 'Click :: Nicht mehr teilnehmen', {
          'event_category': 'Meeting'
        });
      });


    }

    function initCreateMeeting() {
      APP.components.addressInput();

      $('.create-meeting').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
        $('.datepicker').pickadate({
          formatSubmit: 'yyyy-mm-dd',
          hiddenName: true,
          min: true
        });

        $('.timepicker').pickatime({
          interval: 15,
          format: 'HH:i',
          formatSubmit: 'HH:i',
          hiddenSuffix: '',
        });
      }).trigger('cocoon:after-insert');

      $("textarea").autogrow({
        onInitialize: true
      });

      // online meeting switch
      $('.online-meeting-switch').on('change', function() {
        var showOnlineFields = $(this).val() == "true";
        $('#meeting-online-fields').toggle(showOnlineFields);
        $('#meeting-offline-fields').toggle(!showOnlineFields);
        $("#meeting-offline-fields").find("input, select").attr("disabled", showOnlineFields);
      })
      $('.online-meeting-switch:checked').trigger('change');

      // check date radio on upload
      if ($("#meeting_ends_at_date").val()) {
        $(".date-switch :radio[value=range]").prop("checked", true);
      }
      else if ($(".additional-dates").find('.nested-fields').exists()) {
        $(".date-switch :radio[value=multiple]").prop("checked", true);
      }
      else {
        $(".date-switch :radio[value=single]").prop("checked", true);
      }

      // date switch
      $('.date-switch').on('change', function() {
        var checked = $(".date-switch input[type='radio']:checked").val();
        $(".date-fields").hide();
        $("#date-option-"+checked).show();
      }).trigger('change');

      // location field toggle
      $('.select-location-input').on('change', function() {
        var location = $(this).find("option:selected");
        //if (!location.data("graetzl-id")) return;
        $('#meeting-offline-fields [name*="address_street"]').val(location.data("address-street"));
        $('#meeting-offline-fields [name*="address_coords"]').val(location.data("address-coords"));
        $('#meeting-offline-fields [name*="address_zip"]').val(location.data("address-zip"));
        $('#meeting-offline-fields [name*="address_city"]').val(location.data("address-city"));
        $('#meeting-offline-fields [name*="graetzl_id"]').val(location.data("graetzl-id"));
        $('#meeting-offline-fields [name*="address_description"]').val(location.data("address-description"));
      });

      // Trigger Location Toggle on load if location_id param is set
      var location = APP.controllers.application.getUrlVars()["location_id"];
      if (typeof location !== 'undefined') {
        $('.select-location-input').trigger('change');
      }

      // platform_meeting checkbox
      if ($("input:checkbox#meeting_platform_meeting_join_request_attributes_status").exists()) {
          var $platform_join_checkbox = $('input:checkbox#meeting_platform_meeting_join_request_attributes_status');
          if(!document.getElementById('meeting_platform_meeting_join_request_attributes_status').checked) {
            $('div#meeting-platform-meeting-fields').hide();
          }
          $platform_join_checkbox.on('change', function() {
            $('div#meeting-platform-meeting-fields').slideToggle();
          });
      }

      // Hide Elements
      $('.hide').hide();

      $(".event-categories input").on("change", function() {
        maxCategories(); // init on Change
      }).trigger('change');
    }

    function maxCategories() {
      if ($(".event-categories input:checked").length >= 3) {
        $(".event-categories input:not(:checked)").each(function() {
          $(this).prop("disabled", true);
          $(this).parents(".input-checkbox").addClass("disabled");
        });
      } else {
        $(".event-categories input").prop("disabled", false);
        $(".event-categories .input-checkbox").removeClass("disabled");
      }
    }

    return {
      init: init
    };

})();
