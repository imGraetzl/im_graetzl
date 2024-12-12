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
      // Zerlege den Pfad in Teile
      const pathParts = path.split('/');
      // Extrahiere alles nach der zweiten Ebene (index 2 im Array)
      const extractedPath = pathParts.slice(3).join('/');
      window.location.href = $(this).val() + `/${extractedPath}`;
    });
  }

  function initFilter() {

    if ($('.cards-filter').exists()) {
      APP.components.cardBoxFilter.init();
    }

    if ($("section.toolteiler, section.rooms, section.meetings, section.locations, section.coop-demands").exists()) {
      APP.components.categoryFilter.init($('#category-slider'));
    }

  }

  return {
    init: init
  };

})();
