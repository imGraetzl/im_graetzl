APP.components.initUserTooltip = function() {

  // jBox Tooltips for Users
  var user_tooltips = []

  // ------- DESKTOP Hover Tooltips -------
  $(".no-touch .signed-in .avatar-tooltip-trigger").each(function(index, value) {
      var tooltip = $(this).data('tooltip-id');
      var type = $(this).data('tooltip-type');
      user_tooltips[tooltip] = new jBox('Tooltip', {
        addClass:'jBox',
        attach: $(this),
        closeOnMouseleave: true,
        trigger:'mouseenter',
        delayOpen: 500,
        delayClose: 250,
        position: {
          x: 'center',
          y: 'bottom'
        },
        ajax: {
            reload: true,
            setContent: false,
            spinner:true,
            spinnerReposition:false,
            spinnerDelay:0,
            success: function (response) {
              this.setContent(response);
              initTrackingLinks();
              // Analytics
              gtag(
                'event', `Tooltip :: ${type} :: Open`, {
                'event_label': 'Desktop'
              });
            }
        },
      });
  });

  // ------- MOBILE Click Modals -------
  $(".touch .signed-in .avatar-tooltip-trigger").each(function(index, value) {
      var tooltip = $(this).data('tooltip-id');
      var type = $(this).data('tooltip-type');
      user_tooltips[tooltip] = new jBox('Modal', {
        addClass:'jBox',
        attach: $(this),
        trigger:'click',
        preventDefault:true,
        closeButton:true,
        ajax: {
            reload: true,
            setContent: false,
            spinner:true,
            spinnerReposition:false,
            spinnerDelay:0,
            success: function (response) {
              this.setContent(response);
              initTrackingLinks();
              // Analytics
              gtag(
                'event', `Tooltip :: ${type} :: Open`, {
                'event_label': 'Mobile'
              });
            }
        },
      });
  });


  // Init Click Links to be ready after Tooltip is open
  function initTrackingLinks() {
    // Link - Messenger
    $('.user-tooltip-wrp .-messenger a').on('click', function(event){
      var href = $(this).attr('href');
      if (typeof gtag == 'undefined') {
        location.href = href;
      } else {
        event.preventDefault();
        gtag(
          'event', 'Click :: Nachricht senden', {
          'event_category': 'User Tooltip',
          'event_callback': function() {
            location.href = href;
          }
        });
      }
    });
    // Link - Profile
    $('.user-tooltip-wrp .tt-img a, .user-tooltip-wrp a.username, .user-tooltip-wrp .-profile a').on('click', function(event){
      var href = $(this).attr('href');
      if (typeof gtag == 'undefined') {
        location.href = href;
      } else {
        event.preventDefault();
        gtag(
          'event', 'Click :: Profil anzeigen', {
          'event_category': 'User Tooltip',
          'event_callback': function() {
            location.href = href;
          }
        });
      }
    });
  }

  var jBoxTooltips = []
  $(".jBoxTooltip").each(function(index, value) {
      var tooltip = $(this).data('tooltip-id');
      var tooltip_type = $('html').hasClass('no-touch') ? 'Tooltip' : 'Modal';
      jBoxTooltips[tooltip] = new jBox(tooltip_type, {
        addClass:'jBox',
        attach: $(this),
        content:$("#"+tooltip),
        trigger: 'click',
        closeOnClick:true,
        isolateScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });
  });

};



APP.components.initUserTooltip();
