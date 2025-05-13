APP.components.cross_platform_links = (function() {

  function init(node) {
    const currentRegion = document.body.getAttribute('data-region');

    node.querySelectorAll('[cross-platform]').forEach(function(item) {
      const itemRegion = item.getAttribute('cross-platform');
      const host = item.getAttribute('cross-platform-host');

      if (!host || !itemRegion) return;

      if (currentRegion && currentRegion !== itemRegion) {
        item.querySelectorAll('a[href^="/"]').forEach(function(link) {
          const href = link.getAttribute('href');
          if (!href) return;

          const fullUrl = host.replace(/\/$/, '') + href;
          link.setAttribute('href', fullUrl);
        });
      }
    });
  }

  return {
    init: init
  };

})();
