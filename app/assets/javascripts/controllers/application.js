APP.controllers.application = (function() {

  function init() {

    APP.components.headerNavigation.init();
    APP.components.stream.init();
    if($(".welocally").exists()) chooseRegionModal();
    $('.entryUserComment .txt').linkify({ target: "_blank"});
    jBoxGallery();


    // SETUP GTM & ANALYTICS --------------------------------
    var uaid = $("body").attr("data-uaid");
    var userid = $("body").attr("data-userid") || false;

    // LOAD ANALYTICS ASYNC
    var script = document.createElement('script');
    script.src = 'https://www.googletagmanager.com/gtag/js?id=' + uaid;
    script.setAttribute('async', 'async');
    document.head.appendChild(script);

    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('set', 'linker', {'domains': ['imgraetzl.at', 'welocally.at']});
    gtag('consent', 'default', {
        'ad_storage': 'denied',
        'analytics_storage': 'granted'
    });
    gtag('js', new Date());
    if (userid) { gtag('set', {'user_id': userid}); }
    gtag('config', uaid, { 'anonymize_ip': true });

    // Set Analytics Permission Status on Load
    if ($.fn.ihavecookies.preference('analytics') === true) {
        gtag('consent', 'update', {
          'analytics_storage': 'granted'
        });
    }

    // Cookie Consent Banner
    var eventSubmitted = false;
    var cookieOptions = {
        title: 'Cookie Informationen',
        message: 'Wir kommen fast ohne Cookies aus. Es gibt dennoch Cookies, für die wir deine Zustimmung benötigen.',
        delay: 500,
        expires: 90,
        link: '/info/datenschutz',
        uncheckBoxes: false,
        acceptBtnLabel: 'Cookies akzeptieren',
        advancedBtnLabel: 'Einstellungen',
        moreInfoLabel: 'Weitere Informationen',
        cookieTypesTitle: 'Wähle welche Cookies du zulassen möchtest.',
        fixedCookieTypeLabel: 'Notwendige',
        fixedCookieTypeDesc: 'Notwendige Cookies damit die Website funktioniert.',
        cookieTypes: [
          {
            type: 'Analytics',
            value: 'analytics',
            description: 'Cookies die uns dabei helfen die Website zu verbessern.'
          },
        ],
        onAccept: function(){

            myPreferences = $.fn.ihavecookies.cookie();
            myPreferences = myPreferences.join();
            myPreferences == '' ? myPreferences = 'all denied' : myPreferences;

            // Event Tracking - Update Status
            if (!eventSubmitted) {
              gtag(
                'event', 'Accept', {
                'event_category': 'Consent Manager :: Update',
                'event_label': myPreferences
              });
              eventSubmitted = true;
            }

            // Set Analytics Status
            if ($.fn.ihavecookies.preference('analytics') === true) {
              gtag('consent', 'update', {
                'analytics_storage': 'granted'
              });
            } else {
              gtag('consent', 'update', {
                'analytics_storage': 'denied'
              });
            }
        }
    }

    // Load Consent Manager
    $('body').ihavecookies(cookieOptions);

    // Event-Tracking for Load-Status of Consent Manager
    myPreferences = $.fn.ihavecookies.cookie();
    if (myPreferences) {
      myPreferences == '' ? myPreferences = 'all denied' : myPreferences.join();
      gtag(
        'event', 'Status', {
        'event_category': 'Consent Manager :: Init',
        'event_label': 'cookie :: ' + myPreferences
      });
    } else {
      gtag(
        'event', 'Status', {
        'event_category': 'Consent Manager :: Init',
        'event_label': 'no cookie :: consent manager shown'
      });
    }


    // Button for Opening Consent Manager
    $('#ihavecookiesBtn').on('click', function(){
        $('body').ihavecookies(cookieOptions, 'reinit');
        eventSubmitted = false;
    });


    // WeLocally Register and Login Choose Region Modal
    function chooseRegionModal() {
      var redirect_path;
      new jBox('Confirm', {
        addClass:'jBox',
        attach: $(".region-select-link"),
        title: 'Wähle deine Region',
        content: $("#select-region-modal-content"),
        trigger: 'click',
        closeOnEsc: true,
        closeOnClick: 'body',
        blockScroll: true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        cancelButton: 'Abbrechen',
        confirmButton: 'Weiter',
        onOpen: function() {
          redirect_path = this.source.attr('data-urlmethod');
        },
        confirm: function() {
          var redirect_host = $("#select-region-modal-content select").val();
          if (redirect_host != "") {
            var redirect_url =  redirect_host + redirect_path.substring(1);
            window.location.href = redirect_url;
          }
        }
      });
    }

    // Register & Login Modal
    var loginModal = new jBox('Modal', {
      addClass:'jBox',
      attach: '.login-panel-opener',
      content: $('#login-panel-modal'),
      trigger: 'click',
      closeOnClick:'body',
      blockScroll:true,
      animation:{open: 'zoomIn', close: 'zoomOut'},
      width:750
    });

    // Get Target for Mandrill Linking
    $(window).on("load", function() {
      setTimeout(scrollToTarget, 250)
    });

    // Set Screen Mode Class
    enquire
        .register("screen and (max-width:" + APP.config.majorBreakpoints.medium + "px)", {
            deferSetup : true,
            setup : function() {
              $('body').addClass('mob');
            },
            match : function() {
              $('body').addClass('mob');
              $('body').removeClass('desk');
            }
        })
        .register("screen and (min-width:" + APP.config.majorBreakpoints.medium + "px)", {
            deferSetup : true,
            setup : function() {
              $('body').addClass('desk');
            },
            match : function() {
              $('body').addClass('desk');
              $('body').removeClass('mob');
            }
        });

    function scrollToTarget() {
      var target = APP.controllers.application.getUrlVars()["target"];
      if (typeof target !== 'undefined') {
        $('html, body').animate({
          scrollTop: $('#'+target).offset().top
        }, 600);
      }
    }

  }
  // END INIT
  // BEGIN OFTEN USED PUBLIC FUNCTIONS

  function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
  }

  function initMessengerButton() {
    $('#requestMessengerBtn').on('click', function(event){
      event.preventDefault();
      var href = $(this).attr('href');
      var category = $(this).attr('data-category');
      var label = $(this).attr('data-label');
      gtag(
        "event", label +  " :: Click :: Im Messenger kontaktieren", {
        "event_category": category,
        "event_callback": function() {
          location.href = href;
        }
      });
    });
  }

  function initShowContact() {
    $('#contact-infos-block').hide();
    if ($("#show-contact-block").exists()) {
      $('#contact-infos-block').show();
      $('#show-contact-link').hide();
    }

    $('#show-contact-link').on('click', function(event){
      event.preventDefault();
      $('#contact-infos-block').fadeIn();
      $(this).hide();
      var category = $(this).attr('data-category');
      var label = $(this).attr('data-label');
      gtag(
        "event", label + " :: Click :: Kontaktinformationen einblenden", {
        "event_category": category
      });
    });
  }

  var jBoxGallery = function() {
    new jBox('Image', {
      addClass:'jBoxGallery',
      imageCounter:true,
      preloadFirstImage:false,
      closeOnEsc:true,
      createOnInit:true,
      animation:{open: 'zoomIn', close: 'zoomOut'},
      imageSize: 'contain'
    });
  }

  // BETA FLASH for WeLocally
  if (!sessionStorage.getItem('betaflash')) {
    $('#betaflash').show();
  }
  $('#betaflash .close-ico').on('click', function(){
      sessionStorage.setItem('betaflash', true);
      $('#betaflash').fadeOut();
  });

  // ---------------------------------------------------------------------- Returns

  return {
    init: init,
    getUrlVars: getUrlVars,
    initMessengerButton: initMessengerButton,
    initShowContact: initShowContact,
    jBoxGallery: jBoxGallery
  }

})();
