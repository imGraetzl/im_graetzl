APP.controllers.users = (function() {

    function init() {

        APP.components.tabs.initTabs(".tabs-ctrl");

        // User Profile
        if ($("section.userprofile").exists()) {
          if (!$(".tabs-nav li").exists()) { $(".tabs-ctrl").hide(); } // Hide Taby if empty

          // Find and Submit active Tab on Pageload
          if (formSubmit = $('.tabs-ctrl').find("li.active").data("submit")) {
            $(formSubmit).submit();
          }

          // Submit Tab on TabChange
          $('.tabs-ctrl').on("_after", function() {
              var formSubmit = $(this).find("li.active").data("submit");
              var formTarget = $(this).find("li.active").data("target");
              var $cardCrid = $("*[data-behavior="+formTarget+"]");
              if ($cardCrid.is(':empty')) {
                var spinner = $('footer .loading-spinner').clone().removeClass('-hidden');
                if (!$cardCrid.find('.loading-spinner').exists()) {
                  $cardCrid.append(spinner);
                }
                $(formSubmit).submit();
              }
          });

        }

    }

    return {
        init: init
    }

})();
