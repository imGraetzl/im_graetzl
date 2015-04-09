var APP = {
    utils: {},
    components: {},
    pages: {},

    init: function() {
        APP.pages.sitewide.init();
        var pageToInit = $("body").attr("data-page");
        if (APP.pages[pageToInit]) {
            APP.pages[pageToInit].init();
        }
    }
};