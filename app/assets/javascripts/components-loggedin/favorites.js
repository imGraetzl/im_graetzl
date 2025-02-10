APP.components.favorites = (function() {

  function init() {

  }

  function toggle() {

    $('.no-touch [data-behavior="masonry-card"] .cardBoxHeader').on('mouseover', function(event){
      $(this).find('.fav-exchange').hide();
      if ($(this).find('.toggle-admin-ico.jBoxTooltip').exists()) {
        $(this).find('.toggle-admin-ico').show();
      } else {
        $(this).find('.toggle-fav-ico').show();
      }
    });

    $('.no-touch [data-behavior="masonry-card"] .cardBoxHeader').on('mouseleave', function(event){
      $(this).find('.fav-exchange').show();
      if ($(this).find('.toggle-admin-ico.jBoxTooltip').exists()) {
        $(this).find('.toggle-admin-ico').hide();
      } else {
        $(this).find('.toggle-fav-ico').hide();
      }
    });

  }

  return {
    init: init,
    toggle: toggle
  }

})();
