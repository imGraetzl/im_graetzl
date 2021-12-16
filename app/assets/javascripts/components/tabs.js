APP.components.tabs = (function() {

    function initTabs(tabgroup) {
      $(tabgroup).tabslet({
        animation: false,
        active: getFirstNotEmptyTab(tabgroup)
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
      $('.tabs-ctrl').get(0).scrollIntoView();
    }

    function setTab(tab) {
      $('.tabs-ctrl li').removeClass('active');
      $('.tabs-ctrl li#'+tab).addClass('active');
    }

    return {
      initTabs: initTabs,
      openTab: openTab,
      setTab: setTab
    }

})();
