APP.controllers.districts = (function() {

  function init() {
    initMenu();
    initFilter();
  }

  function initMenu() {
    var $select = $(".mapImgBlock .mobileSelectMenu");
    $(".mapImgBlock .links a").each(function() {
      var text = $(this).text();
      var target = $(this).attr("href");
      $select.append("<option value="+target+">"+text+"</option>");
    });

    $select.on("change", function() {
      // Hole die URL-Pfad-Informationen
      const path = window.location.pathname;
      const selectedValue = $(this).val();
    
      if (path.endsWith('/karte') || selectedValue.endsWith('/karte')) {
        // Navigiere nur zur ausgewählten URL ohne 'extractedPath'
        window.location.href = selectedValue;
      } else {
        // Zerlege den Pfad in Teile
        const pathParts = path.split('/');
        // Extrahiere alles nach der ersten Ebene (index 1 im Array)
        const extractedPath = pathParts.slice(3).join('/');
        // Navigiere zur ausgewählten URL mit 'extractedPath'
        window.location.href = selectedValue + `/${extractedPath}`;
      }
    });
  }

  function initFilter() {

    if ($('.cards-filter').exists()) {
      APP.components.cardBoxFilter.init();
    }

    if ($("section.rooms, section.meetings, section.locations, section.coop-demands").exists()) {
      APP.components.categoryFilter.init($('#category-slider'));
    }

  }

  return {
    init: init
  };

})();
