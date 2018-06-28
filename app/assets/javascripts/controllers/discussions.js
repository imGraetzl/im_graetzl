APP.controllers.discussions = (function() {

  function init() {
    APP.controllers.groups.init();
    if ($('.btn-control').exists()) { initControls(); }
    if ($('.follow').exists()) { initFollowing(); }
  }

  function initControls() {
    $('.user-post').mouseenter(function () {
      $(this).find('.btn-control').css('display','flex').hide().fadeIn('slow');
    }).mouseleave(function () {
      $(this).find('.btn-control').hide();
    });
  }

  function initFollowing() {
    $('.follow').on('click', function(){
      $('.follow').toggleClass('-hide');
      //console.log($(this).attr("data-topic"));
    })
  }

  return {
    init: init
  };

})();
