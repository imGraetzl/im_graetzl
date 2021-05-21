APP.controllers.search = (function() {

    function init() {

        $searchInput = $("[data-behavior='searchinput']");

        if ($('.cards-filter').exists()) {
          APP.components.cardFilter.init();
        }

        $('.cards-filter').on('submit', function(event){
          event.preventDefault();

          // Submit Form if Field not empty
          if ($searchInput.val().length >= 3) {
              APP.components.cardFilter.submitForm();
              gtag(
                'event', 'Search', {
                'event_category': 'Searchpage :: Search',
                'event_label': $searchInput.val()
              });
          }

        });
    }

    return {
      init: init
    };

})();
