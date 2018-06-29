APP.controllers.groups = (function() {

    function init() {
      if ($(".group-page").exists()) {
        initShow();
      }
    }

    function initShow() {
      APP.components.tabs.initTabs(".tabs-ctrl");
      $(".all-discussions-link").on("click", function() {
        $(".tabs-ctrl").trigger('show', '#tab-discussions');
      });

      // Toggle Button for new Topic
      $('.btn-new-topic').on( 'click', function() {
        $('#new-topic').slideToggle();
      });

      //$('.introtxt .txt').linkify({ target: "_blank"});

      // JS Action Button Dropdown for Groups
      $('[data-behavior=actionTrigger]').on('click', function(){
        var id = $(this).attr("data-id");
        $(this).jqDropdown('attach', '[data-behavior=actionContainer-'+id+']');
      });

      $('[data-behavior=userTrigger]').on('mouseenter', function(){
        var user_id = $(this).attr("data-user");
        $(this).jqDropdown('attach', '[data-behavior=userContainer-'+user_id+']');
      });

    }

    return {
      init: init
    };

})();
