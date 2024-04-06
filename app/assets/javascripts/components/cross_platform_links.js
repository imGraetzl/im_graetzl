APP.components.cross_platform_links = (function() {

  // Set target '_blank' for foreign region items
  function init(node) {
    let current_region = document.querySelector('body').getAttribute('data-region');
    node.querySelectorAll('[cross-platform]').forEach(function (item) {
      let region = item.getAttribute('cross-platform');
      if (current_region && current_region !== region) {
        item.querySelectorAll(`[href^='/']`).forEach(function (link) {
          link.target = '_blank';
        });
      }
    });
  }

  return {
    init: init
  }

})();
