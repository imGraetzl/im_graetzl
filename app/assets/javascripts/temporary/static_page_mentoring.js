APP.components.initMentoring = (function() {

  // Include the following line in application.js at the end if page is needed (and remove here)
  //= require_directory ./temporary

  function init() {

    $('.group-info').hide();
    var selectedgroup = $('input[name=group]:checked').attr("id");
    $('.group-info.' + selectedgroup).show();

    // Radio Switch for Submitting in selected Group
    $('#group-switch input').on('change', function() {
      var groupaction = $('input[name=group]:checked').val();
      var group = $('input[name=group]:checked').attr("id");
      $('#groupform').attr('action', groupaction);

      $('.group-info').hide();
      $('.group-info.' + group).show();

    });

    // Change Wording of Notice Message for Mentoring Registrations
    if ($("#flash .notice").exists()) {
      if ( $("#flash .notice").text().indexOf('Vielen Dank für Deine Registrierung') >= 0 ){
        // Modifiy Message for Mentoring
        $("#flash .notice").html('Vielen Dank für Deine Registrierung. Du bist nun angemeldet und kannst das <a href="#teilnahme">Teilnahme Formular</a> (unterhalb) ausfüllen.');
      }
    }

    if ($("#card-slider").exists()) {
      $('#card-slider').lightSlider({
        item: 2,
        slideMove: 2, // slidemove will be 1 if loop is true
        auto: true,
        loop: true,
        pause: 10000,
        controls: false,
        pager: true,
        responsive : [
          {
            breakpoint:850,
            settings: {
              item: 2,
              slideMove: 2,
            }
          },
          {
            breakpoint:530,
            settings: {
              item: 1,
              slideMove: 1
            }
          }
        ]
      });
    }

  }

  return {
    init: init,
  }

})();
