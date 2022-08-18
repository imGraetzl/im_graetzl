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

  function initMobileNav() {
    var $dropdown = $(".navigation-bar .input-select select");
    $(".navigation-bar .iconfilter").not('.createentry, .loginlink').each(function() {
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
  }

  return {
    init: init
  };

})();
