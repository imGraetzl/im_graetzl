APP.controllers.search = (function() {

    function init() {

        $searchInput = $("[data-behavior='searchinput']");

        if ($('.cards-filter').exists()) {
          APP.components.cardFilter.init();
        }

        $('.cards-filter').on('submit', function(event){
          event.preventDefault();

          // Submit Form if Field not empty
          if ($searchInput.val().length > 0) {
              APP.components.cardFilter.submitForm();
          }

        });
    }

    return {
      init: init
    };

})();
