var APP = {
    utils: {},
    components: {},
    pages: {},

    init: function() {
        APP.pages.sitewide.init();
        var pageToInit = $("body").attr("data-page");
        APP.pages[pageToInit].init();
    }
};