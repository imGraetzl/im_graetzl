APP.controllers.wien = (function() {

    var map = APP.components.graetzlMap;

    function init() {
        var $select = $(".mapImgBlock .mobileSelectMenu");
        $(".mapImgBlock .links a").each(function() {
            var text = $(this).text();
            var target = $(this).attr("href");
            $select.append("<option value="+target+">"+text+"</option>");
        });
        $select.on("change", function() {
            window.location.href = $(this).val();
        });

        APP.components.addressSearchAutocomplete();

        if ($("#graetzlMapWidget").exists()) {
          initMap();
        }

        initFilter();
    }


    function initMap() {
        var mapdata = $('#graetzlMapWidget').data('mapdata');
        map.init(function() {
            map.showMapDistrict(mapdata.districts, {
                interactive: true
            });
        });
    }

    function initFilter() {
      $(".cards-filter a").featherlight({ targetAttr: 'href', persist: true, root: $(".cards-filter") });

      $(".cards-filter").on("click", ".filter-button", function() {
        var currentModal = $.featherlight.current();
        var selectedInputs = currentModal.$content.find(".filter-input :selected, .filter-input :checked");
        var label = selectedInputs.map(function() { return $(this).data("label"); }).get().join(", ");
        $('.cards-filter a[href="' + currentModal.$content.selector + '"]').text(label);
        $('.autosubmit-filter').submit();
        currentModal.close();
      });

      $('.district-select').SumoSelect({
          search: true,
          searchText: 'Suche nach Bezirk.',
          placeholder: 'Bezirk auswählen',
          csvDispCount: 5,
          captionFormat: '{0} Bezirk ausgewählt'
      });

      $('.autosubmit-filter').submit();
    }

    return {
        init: init
    }

})();
