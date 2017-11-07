APP.controllers.graetzls = (function() {

    var map =  APP.components.graetzlMap;
    var grid = APP.components.masonryFilterGrid;

    function init() {
      initMap();
      initFilter();
    }

    function initMap() {
      var mapdata = $('#graetzlMapWidget').data('mapdata');
      map.init(function() {
        map.showMapGraetzl(mapdata.graetzls, {
          style: $.extend(map.styles.rose, { weight: 4, fillOpacity: 0.2 })
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

      $('.district-select').SumoSelect({
          search: true,
          searchText: 'Suche nach Bezirk.',
          placeholder: 'Bezirk auswählen',
          csvDispCount: 5,
          captionFormat: '{0} Bezirk ausgewählt'
      });

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
