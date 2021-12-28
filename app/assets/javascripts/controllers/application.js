APP.controllers.application = (function() {

  function init() {
    
    APP.components.headerNavigation.init();
    APP.components.stream.init();

    if($(".welocally").exists()) chooseRegionModal();
    $('.txtlinky').linkify({ target: "_blank"});
    jBoxGallery();

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

  }
  // END INIT
  // BEGIN OFTEN USED PUBLIC FUNCTIONS

  function scrollToTarget() {
    var target = APP.controllers.application.getUrlVars()["target"];
    if (typeof target !== 'undefined') {
      $('html, body').animate({
        scrollTop: $('#'+target).offset().top
      }, 600);
    }
  }

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
    scrollToTarget: scrollToTarget,
    initMessengerButton: initMessengerButton,
    initShowContact: initShowContact,
    jBoxGallery: jBoxGallery
  }

})();
