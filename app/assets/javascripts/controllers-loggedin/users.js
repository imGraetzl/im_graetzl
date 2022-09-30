APP.controllers_loggedin.users = (function() {

    function init() {

        APP.components.notificationSettings.init();
        APP.components.addressInput();

        // User Profile
        if ($("section.userprofile").exists()) {
          if (!$(".tabs-nav li").exists()) { $(".tabs-ctrl").hide(); } // Hide Tab if empty

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

        // User Setup
        if ($("section.usersetup").exists()) { addActionCard(); }
        if ($("section.usersetup.-favorite-graetzls").exists()) { initFavoriteGraetzls(); }
        if ($("section.usersetup.-payment-method").exists()) { initPaymentMethod(); }

        if ($("section.usersetup.-meetings").exists()) {
          $('.autosubmit-stream').submit();
          $(".autosubmit-stream").bind('ajax:complete', function() {
            addActionCard();
          });
        }

        function addActionCard() {
          if ($(".action-card-container").exists()) {
            var actionCard = $(".action-card-container").children().first().clone();
            var cardGrid = $('.cardBoxCollection');
            if (cardGrid.children(":eq(1)").exists()) {
              cardGrid.children(":eq(1)").after(actionCard);
            } else {
              cardGrid.append(actionCard);
            }
          }
        }

        // Favorite Graetzl Setup Page
        function initFavoriteGraetzls() {
          APP.components.graetzlSelectFilter.init($('#area-select'));
          // Submit IDS
          $(".map-form").on("submit", function() {
            $(".fav-desktop .favorite-graetzls a").each(function() {
              $(".map-form").append(
                "<input type='hidden' name='user[favorite_graetzl_ids][]' value=" + $(this).data('id') + ">"
              );
            })
          });
          // Remove Current Homegraetzl from Favorite Select Dropdown (Mobileversion)
          var current_home_graetzl_name = $("#current_home_graetzl").data('name');
          var current_home_graetzl_id = $("#current_home_graetzl").data('id');
          $(".fav-mobile .fav_graetzls ul.options label").each(function() {
              if ($(this).text().indexOf(current_home_graetzl_name) !== -1 ) {
                $(this).parent().remove();
              }
          });
          $(".fav-mobile .fav_graetzls option[value="+current_home_graetzl_id+"]").remove();
        }

        // Payment Method
        function initPaymentMethod() {
          APP.components.stripePayment.init();
          $('#change_payment').on("click", function() {
            $("#payment-form").slideToggle();
          });
        }

    }

    return {
        init: init
    }

})();
