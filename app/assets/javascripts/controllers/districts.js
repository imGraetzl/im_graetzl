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
      window.location.href = $(this).val();
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
