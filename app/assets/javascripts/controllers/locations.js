APP.controllers.locations = (function() {

    function init() {
        if ($("section.location-page").exists()) initLocationPage();
    }

    function initLocationPage() {
      APP.controllers.application.initMessengerButton();

      if ($("#leafletMap").exists()) APP.components.leafletMap.init($('#leafletMap'));

      var mobCreate = new jBox('Modal', {
        addClass:'jBox',
        attach: '#editPage',
        content: $('#jBoxEditPage'),
        trigger: 'click',
        closeOnClick:true,
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });

      $('.autosubmit-stream').submit();

      // open comments if post hash exists
      var hash = window.location.hash.substr(1);
      if (hash.indexOf("location_post") != -1) {
        $( "#" + hash + " .show-all-comments-link" ).click();
      }

      enquire
          //mobile mode
          .register("screen and (max-width:" + APP.config.majorBreakpoints.large + "px)", {
              match : function() {
                  $('.stream').insertAfter('.sideBar');
              }
          })
          //desktop mode
          .register("screen and (min-width:" + APP.config.majorBreakpoints.large + "px)", {
              match : function() {
                  $('.stream').appendTo('.mainContent');
              }
          });
    }

    return {
      init: init
    };

})();
