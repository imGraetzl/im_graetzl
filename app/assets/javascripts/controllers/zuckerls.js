APP.controllers.zuckerls = (function() {

    function init() {
      if ($("section.createzuckerl").exists()) {
        APP.components.createzuckerl.init();
      }
    }

    return {
      init: init
    };

})();
