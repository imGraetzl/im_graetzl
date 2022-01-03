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

  }

  return {
      init: init
  }

})();
