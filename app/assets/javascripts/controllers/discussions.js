APP.controllers.discussions = (function() {

  function init() {
    APP.controllers.groups.init();
    initControls();
    if ($('.follow').exists()) { initFollowing(); }
    if ($('.discussion-area .discussion-infos').exists()) { initDiscussionTab(); }
  }

  function initDiscussionTab() {
    $(".tabs-nav .-topics").addClass('active');
  }

  function initControls() {
    $(".discussion-area").on('click', '.edit-post-link', function() {
      $(this).parents(".user-post").addClass("editing");
      $('textarea').autoheight();
    }).on('click', '.cancel-edit-link', function() {
      $(this).parents(".user-post").removeClass("editing");
    });

  }

  function initFollowing() {
    $('.follow').on('click', function(){
      $('.follow').toggleClass('-hide');
    })
  }

  return {
    init: init
  };

})();
