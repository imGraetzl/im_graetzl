APP.components.favorites = (function() {

  function init() {

  }

  function toggle() {

    $('.no-touch [data-behavior="masonry-card"] .cardBoxHeader').on('mouseover', function(event){
      $(this).find('.fav-exchange').hide();
      $(this).find('.toggle-fav-ico').show();
    });

    $('.no-touch [data-behavior="masonry-card"] .cardBoxHeader').on('mouseleave', function(event){
      $(this).find('.fav-exchange').show();
      $(this).find('.toggle-fav-ico').hide();
    });

  }

  return {
    init: init,
    toggle: toggle
  }

})();
