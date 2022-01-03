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

        if ($("#filter-modal-bezirk").exists()) {
          APP.components.graetzlSelectFilter.init($("#filter-modal-bezirk"));
        }

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
