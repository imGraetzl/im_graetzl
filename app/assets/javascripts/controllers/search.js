APP.controllers.search = (function() {

  function init() {
    //if ($("section.search-section").exists()) search();
    radio_submit();
  }

  // Search
  function radio_submit() {
    $( 'form' ).change(function() {
      if(!$('#q').val()) {
        return
      } else {
        $('form').submit();
      }
    });
  }


  return {
    init: init,
  }

})();
