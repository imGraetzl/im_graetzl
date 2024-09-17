var APP = {

    config: {
        notificationPollInterval: 120*1000,
        majorBreakpoints: {
            //breakpoints should be the same like in the file include_media.scss
            //TODO: maybe use one shared JSON config for JS and SASS breakpoints
            small: 320,
            medium: 650,
            large: 1015
        }
    },

    utils: {},
    components: {},
    controllers: {},
    controllers_loggedin: {},

    init: function() {
        APP.controllers.application.init();
        var pageToInit = $("body").attr("data-controller");
        APP.controllers[pageToInit] && APP.controllers[pageToInit].init();
    }
};
