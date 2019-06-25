APP.controllers.messenger = (function() {

  function init() {
    initMessenger();
    //if ($('.xyz').exists()) { initFunction(); }
  }

  function initMessenger() {

    // Jump to end of Chat Messages -> Show newest.
    $(".chat-panel").scrollTop($(".chat-panel")[0].scrollHeight);

    // When scrolling to top of Chat Messages -> Load older before
    var loading_bubbles = false;
    var numberMessages = 5;
    var insert_fake_content = $('.chat-bubble:nth-child(-n+'+numberMessages+')'); // Fake Clone Content
    var loadedBubbleHeight = 0;
    var loading_spinner_height = 0;

    $(".chat-panel").bind('scroll', function(e) {

      var elem = $(e.currentTarget);

      if (elem.scrollTop() == 0 && loading_bubbles == false) {
        loading_bubbles = true;
        //console.log("top rechaed"); // Check for older Messages and load them
        $('.loading-spinner').clone().insertBefore('.chat-bubble:first').hide().fadeIn('200', function(){
          setTimeout(function() { // Animate Time for Ajax
            loading_spinner_height = $('.chat-panel .loading-spinner').outerHeight(true);
            $('.chat-panel .loading-spinner').remove();

            // Demo Bubbles for loading more content ...
            insert_fake_content.clone().insertBefore('.chat-bubble:first').hide().fadeIn().addClass('inserted');

            // Get sum height of all inserted bubbles
            $(".chat-bubble.inserted").each(function(){
                loadedBubbleHeight = loadedBubbleHeight + $(this).outerHeight(true);
            });

            // Move to correct position, so that content is at same posotion after inserting.
            $(".chat-panel").scrollTop(loadedBubbleHeight - loading_spinner_height);

            // Resets
            $(".chat-bubble.inserted").removeClass('inserted'); // remove class after calculation
            loadedBubbleHeight = 0; // reset bubbleheight
            loading_bubbles = false; // reset loading to default
          }, 2000);
        });
      }
      // Trigger Scroll to Bottom
      //if (elem[0].scrollHeight - elem.scrollTop() == elem.outerHeight() {
        //console.log("bottom rechaed");
      //}
    });

    $('select#compose-user-select').SumoSelect({
      search: true,
      searchText: 'Suche nach User.',
      placeholder: 'User auswählen',
      csvDispCount: 5
    });

  }

  return {
    init: init
  };

})();
