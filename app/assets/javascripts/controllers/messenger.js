APP.controllers.messenger = (function() {

  function init() {
    initMessenger();
    //if ($('.xyz').exists()) { initFunction(); }
  }

  function initMessenger() {

    // Jump to end of Chat Messages -> Show newest.
    $(".chat-panel").scrollTop($(".chat-panel")[0].scrollHeight);

    // When scrolling to top of Chat Messages -> Load older

    var loading_bubbles = false;
    var numberMessages = 8;
    var insert_fake_content = $('.chat-bubble:nth-child(-n+'+numberMessages+')'); // Fake Clone Content

    $(".chat-panel").bind('scroll', function(e) {

      var elem = $(e.currentTarget);

      if (elem.scrollTop() == 0 && loading_bubbles == false) {
        loading_bubbles = true;
        //console.log("top rechaed"); // Check for older Messages and load them
        $('.loading-spinner').clone().insertBefore('.chat-bubble:first').hide().fadeIn('200', function(){
          setTimeout(function() { // Animate Time for Ajax
            var loading_spinner_height = $('.chat-panel .loading-spinner').outerHeight(true);
            console.log(loading_spinner_height);
            $('.chat-panel .loading-spinner').remove();
            // Demo for loading more content ...
            insert_fake_content.clone().insertBefore('.chat-bubble:first').hide().fadeIn();
            // Move to correct position, so that content is at same posotion after inserting. check on different screen sizes !!!! Mobile Problems ..?!
            $(".chat-panel").scrollTop(insert_fake_content.outerHeight(true) * numberMessages - loading_spinner_height); // 4 Bubbles inserted Fake Content
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
