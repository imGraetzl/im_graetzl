APP.controllers.districts = (function() {

  function init() {
    initMenu();
    initMap();
    initFilter();
  }

  function initMenu() {
    var $select = $(".mapImgBlock .mobileSelectMenu");
    $(".mapImgBlock .links a").each(function() {
      var text = $(this).text();
      var target = $(this).attr("href");
      $select.append("<option value="+target+">"+text+"</option>");
      //$(".mapImgBlock .links").after($select);
    });

    $select.on("change", function() {
      window.location.href = $(this).val();
    });
  }

  function initMap() {
    var map = APP.components.graetzlMap;
    var mapdata = $('#graetzlMapWidget').data('mapdata');
    map.init(function() {
      map.showMapDistrict(mapdata.districts, {
        style: $.extend(map.styles.mint, {
          weight: 0,
          fillOpacity: 0.5
        })
      });
      map.showMapGraetzl(mapdata.graetzls, {
        interactive: true,
        zoomAfterRender: false
      });
    });
  }

  function initFilter() {
    $('.autosubmit-filter').on('ajax:success', function() {
      APP.components.cardBox.moveActionCard3rd();
    });

    $('.autosubmit-filter').submit();
  }

  return {
    init: init
  };

})();
