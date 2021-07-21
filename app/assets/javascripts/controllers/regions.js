APP.controllers.regions = (function() {

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
        APP.components.areaMap.init($('#area-map'), { interactive: true });

        if ($("#filter-modal-bezirk").exists()) {
          APP.components.graetzlSelectFilter.init($("#filter-modal-bezirk"));
        }

        if ($("#filter-modal-district").exists()) {
          APP.components.districtSelectFilter.init($("#filter-modal-district"));
        }

        if ($('.cards-filter').exists()) {
          APP.components.cardFilter.init();
        }

        if ($("#card-slider").exists()) {
          APP.components.cardSlider.init($("#card-slider"));
        }

        if ($("section.toolteiler, section.rooms, section.meetings, section.locations").exists()) {
          APP.components.cardFilterSlider.init($('#category-slider'));
        }

        initMobileNav();
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
