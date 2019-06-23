APP.controllers.messenger = (function() {

  function init() {
    initMessenger();
    //if ($('.xyz').exists()) { initFunction(); }
  }

  function initMessenger() {

    // Jump to end of Chat Messages -> Show newest.
    $(".chat-panel").scrollTop($(".chat-panel")[0].scrollHeight);

    // Scroll to top of Chat Messages -> Load more
    var loading_bubbles = false;
    $(".chat-panel").bind('scroll', function(e) {

      var elem = $(e.currentTarget);
      var insert_content = $('.chat-bubble:nth-child(-n+4)'); // Fake Clone Content

      if (elem.scrollTop() == 0 && loading_bubbles == false) {
        loading_bubbles = true;
        //console.log("top rechaed"); // Check for older Messages and load them
        $('.loading-spinner').clone().insertBefore('.chat-bubble:first').hide().fadeIn('200', function(){
          setTimeout(function() { // Animate Time for Ajax
            $('.chat-panel .loading-spinner').remove();
            // Demo for loading more content ...
            insert_content.clone().insertBefore('.chat-bubble:first').hide().fadeIn();

            // Move to correct position, so that content is at same posotion after inserting. check on different screen sizes !!!! evtl anders lösen?!
            $(".chat-panel").scrollTop(insert_content.outerHeight() * 4); // 4 Bubbles inserted Fake Content
            loading_bubbles = false; // reset loading to default
          }, 2000);
        });
      }
      // Trigger Scroll to Bottom
      //if (elem[0].scrollHeight - elem.scrollTop() == elem.outerHeight() {
        //console.log("bottom rechaed");
      //}
    });

  }

  return {
    init: init
  };

})();
