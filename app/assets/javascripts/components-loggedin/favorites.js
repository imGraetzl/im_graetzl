APP.components.favorites = (function() {

  function init() {

  }

  function toggle() {

    $('.no-touch [data-behavior="masonry-card"] .cardBoxHeader').on('mouseover', function(event){
      showElement($(this));
    });

    $('.no-touch [data-behavior="masonry-card"] .cardBoxHeader').on('mouseleave', function(event){
      hideElement($(this));
    });

    $('.touch .admin [data-behavior="masonry-card"] .categoryicon').on('click', function (event) {
      const $toggleAdmin = $(this).find('.toggle-admin-ico.jBoxTooltip');
      if (!$toggleAdmin.length) return; // Touch-Verhalten nur für Admin-Version
      const wasPreviewed = $(this).data('previewed') === true;
      if (!wasPreviewed) {
        event.preventDefault();
        $(this).data('previewed', true);
        showElement($(this));
      } else {
        $(this).data('previewed', false);
        //hideElement($(this));
      }
    });

  }

  function showElement(el) {
    if (!el) return;
    $(el).find('.fav-exchange').hide();
    if ($(el).find('.toggle-admin-ico.jBoxTooltip').exists()) {
      $(el).find('.toggle-admin-ico').show();
    } else {
      $(el).find('.toggle-fav-ico').show();
    }
  }

  function hideElement(el) {
    if (!el) return;
    $(el).find('.fav-exchange').show();
    if ($(el).find('.toggle-admin-ico.jBoxTooltip').exists()) {
      $(el).find('.toggle-admin-ico').hide();
    } else {
      $(el).find('.toggle-fav-ico').hide();
    }
  }

  return {
    init: init,
    toggle: toggle
  }

})();
