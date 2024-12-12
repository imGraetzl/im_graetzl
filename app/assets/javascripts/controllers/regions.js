APP.controllers.regions = (function() {

    function init() {
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
          // Extrahiere alles nach der ersten Ebene (index 1 im Array)
          const extractedPath = pathParts.slice(2).join('/');
          window.location.href = $(this).val() + `/${extractedPath}`;
        });

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
