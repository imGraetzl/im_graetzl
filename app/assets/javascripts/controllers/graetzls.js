APP.controllers.graetzls = (function() {

    function init() {
      initMap();
      initFilter();
      initMobileNav();
    }

    function initMap() {
      var mapdata = $('#graetzlMapWidget').data('mapdata');
      var map =  APP.components.graetzlMap;
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
        var link = $('.cards-filter a[href="' + currentModal.$content.selector + '"]');
        if (selectedInputs.length > 0) {
          var label = selectedInputs.map(function() { return $(this).data("label"); }).get().join(", ");
          link.text(label);
        } else {
          link.text(link.data("no-filter-label"));
        }
        $('.autosubmit-filter').submit();
        currentModal.close();
      });


      APP.components.graetzlSelectFilter.init($('.district-select'), $('.graetzl-select'));

      var grid = APP.components.masonryFilterGrid;

      $('.autosubmit-filter').on('ajax:success', function() {
        grid.initGrid();
      });

      $('.link-load').on('ajax:success', function() {
        grid.adjustNewCards();
      });

      $('.autosubmit-filter').submit();
    }

    function initMobileNav() {
      var $dropdown = $(".filter-stream .input-select select");
      $(".filter-stream .iconfilter").not('.createentry, .loginlink').each(function() {
          var $this = $(this),
              link = $this.prop('href'),
              txt = $this.find('.txt').text();

          $dropdown.append(getOption());
          $dropdown.on('change', function() {
              document.location.href = $dropdown.val();
          });

          function getOption() {
              if($this.hasClass('active'))
                  return '<option selected value="'+ link +'">'+ txt +'</option>';
              return '<option value="'+ link +'">'+ txt +'</option>';
          }

      });
      $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');
    }

    return {
      init: init
    };

})();
