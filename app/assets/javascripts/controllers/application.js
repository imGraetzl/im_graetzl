APP.controllers.application = (function() {

  function init() {

    APP.components.headerNavigation.init();
    APP.components.stream.init();
    APP.components.search.init();
    APP.components.fileUpload.init();
    jBoxGallery();
    if($(".welocally").exists()) chooseRegionModal();

    FastClick.attach(document.body);

    window.cookieconsent_options = {
      "message":"Diese Website verwendet Cookies. Indem Sie weiter auf dieser Website navigieren, stimmen Sie unserer Verwendung von Cookies zu.",
      "dismiss":"OK!","learnMore":"Mehr Information",
      "link":"https://www.imgraetzl.at/info/datenschutz",
      "theme": false
    };

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

    // Conversion Tracking
    if (window.location.hostname == 'www.imgraetzl.at') {
      $(document).ready(function() {
        if ($("#flash .notice").exists()) {

          // Registration
          if ( $("#flash .notice").text().indexOf('Super, du bist nun registriert!') >= 0 ){
            gtag('event', 'sign_up', {'event_category': 'Registration'}); // GA
          }

        }
      });
    }

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

  // ---------------------------------------------------------------------- Returns

  return {
    init: init,
    getUrlVars: getUrlVars,
    jBoxGallery: jBoxGallery
  }

})();
