APP.controllers.application = (function() {

  function init() {

    APP.components.headerNavigation.init();
    APP.components.stream.init();

    if($(".welocally").exists()) chooseRegionModal();
    if ($("[data-jbox-image]").exists()) jBoxGallery();
    $('.txtlinky').linkify({ target: "_blank"});
    $('textarea').autoheight();

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
      // Open all Comments
      $("#"+target).parents(".post-comments").find(".show-all-comments").click();
      // Scroll to Comment
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
      var label = $(this).attr('data-label');
      gtag(
        "event", `Im Messenger kontaktieren :: ${label}`, {
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
      var label = $(this).attr('data-label');
      gtag(
        "event", `Kontaktinformationen einblenden :: ${label}`
      );
    });
  }

  // Login Modal -------------------------
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

  // gallery modal -------------------------
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

  // video modal -------------------------
  if($("#videoIframe").exists() && $(window).width() < 800) {
    // adjust iframe height on smaller screens
    var iframe = document.getElementById("videoIframe");
    var iframeHeight = $(window).width() * 0.56;
    iframe.style.height = iframeHeight + 'px';
  }
  var vidsrc;
  var videoModal = new jBox('Modal', {
    addClass:'jBox jBoxVideo',
    attach: '.jBoxVideo',
    content: $('#jBoxVideoContent'),
    trigger: 'click',
    closeOnEsc:true,
    closeOnClick:true,
    animation:{open: 'zoomIn', close: 'zoomOut'},
    onOpen: function () {
      vidsrc = $('#videoIframe').attr('data-src');
      $('#videoIframe').attr('src',vidsrc + "?autoplay=1");
    },
    onClose: function () {
      $('#videoIframe').attr('src', vidsrc);
    }
  });

  // VIDEO Embed
  document.querySelectorAll(':is(vimeo-embed, youtube-embed) button').forEach(button => button.addEventListener('click', () => {
    const video = button.previousElementSibling;
    video.src = video.dataset.src;
  }));

  // Toggable Headlines
  $('.-toggable h3').on('click', function() {
    $toggleContainer = $(this).closest('.-toggable');
    $toggleContainer.find('.-toggle-content').slideToggle();
    if ($toggleContainer.hasClass('-open')) {
      $toggleContainer.removeClass('-open');
    } else {
      $toggleContainer.addClass('-open');
    }
  });

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
    jBoxGallery: jBoxGallery,
    loginModal: loginModal
  }

})();
