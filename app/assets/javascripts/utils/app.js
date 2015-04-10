var APP = {
    utils: {},
    components: {},
    controllers: {},

    init: function() {
        APP.controllers.application.init();
        var pageToInit = $("body").attr("data-controller");
        if (APP.controllers[pageToInit]) {
            APP.controllers[pageToInit].init();
        }
    }
};