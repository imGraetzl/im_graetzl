APP.controllers_loggedin.search = (function() {

    function init() {

        $searchInput = $("[data-behavior='searchinput']");

        if ($('.cards-filter').exists()) {
          APP.components.cardBoxFilter.init();
        }

        $('.cards-filter').on('submit', function(event){
          event.preventDefault();

          // Submit Form if Field not empty
          if ($searchInput.val().length >= 3) {
              APP.components.cardBoxFilter.submitForm();
              gtag(
                'event', 'Search :: Searchpage :: Results', {
                'event_label': $searchInput.val()
              });
          }

        });
    }

    return {
      init: init
    };

})();
