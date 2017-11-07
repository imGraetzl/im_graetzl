APP.controllers.wien = (function() {

    var map = APP.components.graetzlMap;
    var grid = APP.components.masonryFilterGrid;

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
      $(".filter-selection-text a").featherlight({ targetAttr: 'href', persist: true, root: $(".cards-filter") });

      $(".cards-filter").on("click", ".filter-button", function() {
        var currentModal = $.featherlight.current();
        var selectedInputs = currentModal.$content.find(".filter-input :selected, .filter-input :checked");
        var label = selectedInputs.map(function() { return $(this).data("label"); }).get().join(", ");
        $('.cards-filter a[href="' + currentModal.$content.selector + '"]').text(label);
        $('.autosubmit-filter').submit();
        currentModal.close();
      });

      APP.components.graetzlSelectFilter.init($('.district-select'), $('.graetzl-select'));

      $('.autosubmit-filter').on('ajax:success', function() {
        grid.init();
      });

      $('.link-load').on('ajax:success', function() {
        grid.adjustNewCards();
      });

      $('.autosubmit-filter').submit();
    }

    return {
      init: init
    };

})();
