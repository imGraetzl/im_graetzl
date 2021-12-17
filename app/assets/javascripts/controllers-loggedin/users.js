APP.controllers_loggedin.users = (function() {

    function init() {

        APP.components.notificationSettings.init();
        APP.components.addressInput();

        if ($("section.usersetup.-favorite-graetzls").exists()) { initFavoriteGraetzls(); }

        if ($("section.usersetup.-location").exists()) { addActionCard(); }
        if ($("section.usersetup.-toolteiler").exists()) { addActionCard(); }
        if ($("section.usersetup.-rooms").exists()) { addActionCard(); }
        if ($("section.usersetup.-groups").exists()) { addActionCard(); }
        if ($("section.usersetup.-coop-demands").exists()) { addActionCard(); }
        if ($("section.usersetup.-zuckerl").exists()) { addActionCard(); }

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

    }

    return {
        init: init
    }

})();
