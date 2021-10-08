APP.controllers.home = (function() {

  function init() {
    if($("section.homeRegion").exists()) initHomeRegion();
    if($("section.homeWeLocally").exists()) initHomePlatform();
  }

  // WeLocally Homepage
  function initHomePlatform() {

    if (navigator.geolocation && window.location.pathname === '/') {

      function successPosition(position) {
        console.log(position.coords);
        //var testcoords = { latitude: 48.511296, longitude: 14.5047566, } // TESTDATA
        $.ajax({
          type: "POST",
          url: "/geolocation",
          data: position.coords
          //data: testcoords
        })
      }

      function errorPosition(error) {
        console.log(error);
      }

      navigator.geolocation.getCurrentPosition(successPosition,errorPosition,{timeout:500});

    }
  }

  // Region Homepage
  function initHomeRegion() {

    // Only load when map is shown
    if ($('#area-map').is(":visible")) {
      APP.components.areaMap.init($('#area-map'), { interactive: false, zoomSnap:0.25 });
    }

    // SupporterBox Hide
    $('.close-ico').on('click', function(event){
      $(this).parent().fadeOut('fast');
    });

    // Logo Mouseover
    var titletext = $(".region-logos .title").text();

    $('.region-logos .-logo img').on('mouseover', function(event){
      $( ".region-logos .title" ).text($(this).data('label'));
    });

    $('.region-logos').on('mouseleave', function(event){
      $( ".region-logos .title" ).text(titletext);
    });


    // Mobile Nav
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
          if ($this.hasClass('active')) {
            return '<option selected value="'+ link +'">'+ txt +'</option>';
          } else {
            return '<option value="'+ link +'">'+ txt +'</option>';
          }
        }

    });

  }

  return {
      init: init
  }

})();
