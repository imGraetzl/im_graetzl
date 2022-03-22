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
