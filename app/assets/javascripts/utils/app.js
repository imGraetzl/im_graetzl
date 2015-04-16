var APP = {

    config: {
      adressSearchOpenGov: 'http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address='
    },

    utils: {},
    components: {},
    controllers: {},

    init: function() {
        APP.controllers.application.init();
        var pageToInit = $("body").attr("data-controller");
        APP.controllers[pageToInit] && APP.controllers[pageToInit].init();
    }
};