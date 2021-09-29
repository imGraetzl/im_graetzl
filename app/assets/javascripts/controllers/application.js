APP.controllers.application = (function() {

  function init() {

    APP.components.headerNavigation.init();
    APP.components.stream.init();
    APP.components.search.init();
    APP.components.fileUpload.init();
    jBoxGallery();
    if($(".welocally").exists()) chooseRegionModal();

    FastClick.attach(document.body);

    // Cookie Consent Banner
    var eventSubmitted;
    var options = {
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
            gtag('consent', 'update', {
              'analytics_storage': 'granted'
            });
            if (!eventSubmitted) {
              gtag(
                'event', 'Accepted', {
                'event_category': 'Consent Manager',
                'event_label': ''+myPreferences+''
              });
              eventSubmitted = true;
            }
        }
    }

    $(document).ready(function() {
        $('body').ihavecookies(options);

        if ($.fn.ihavecookies.preference('analytics') === true) {
            gtag('consent', 'update', {
              'analytics_storage': 'granted'
            });
        }

        $('#ihavecookiesBtn').on('click', function(){
            $('body').ihavecookies(options, 'reinit');
            eventSubmitted = false;
        });
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

  function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
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
    jBoxGallery: jBoxGallery
  }

})();
