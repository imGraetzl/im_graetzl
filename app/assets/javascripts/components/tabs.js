APP.components.tabs = (function() {

    function initTabs(tabgroup, container) {

      if (typeof container == "undefined") {
        container = false;
        tabcontent = tabgroup;
      } else {
        tabcontent = container;
      }

      $(tabgroup).tabslet({
        animation: false,
        active: getFirstNotEmptyTab(tabcontent),
        container: container
      });
      $(tabgroup).find("li.active").click();
    }


    function getFirstNotEmptyTab(tabgroup) {
      if (window.location.hash && $(window.location.hash).length) {
        return $(tabgroup).find('[id^="tab-"]').index($(window.location.hash)) + 1;
      } else {
        return 1;
      }
    }

    function openTab(tab) {
      $('.tabs-ctrl').trigger('show', '#tab-' + tab);
      //$('.tabs-ctrl').get(0).scrollIntoView();
    }

    function initPageTab() {
      var tab = APP.controllers.application.getUrlVars()["pagetab"];
      if (typeof tab !== 'undefined') {
        openTab(tab);
      }
    }

    function setTab(tab) {
      $('.tabs-ctrl li').removeClass('active');
      $('.tabs-ctrl li#'+tab).addClass('active');
    }

    return {
      initTabs: initTabs,
      initPageTab: initPageTab,
      openTab: openTab,
      setTab: setTab
    }

})();
