APP.controllers.polls = (function() {

  function init() {
    if ($(".poll-form").exists()) { pollForm(); }
    if (!$('body.signed-in').exists()) { loginForm(); }
  }

  function pollForm() {

    // Poll Registrations
    if ($("#flash .notice").exists()) {
      if ( $("#flash .notice").text().indexOf('Vielen Dank für Deine Registrierung') >= 0 ){
        // Modifiy Message for Poll
        $("#flash .notice").html('Vielen Dank für Deine Registrierung. Du bist nun angemeldet und kannst mit der Umfrage fortfahren.');
      }
    }

    $(".-save").on( "click", function( event ) {

      let submit = true;

      $(".pollquestion[data-required='true']").each(function( index ) {

        $(this).removeClass('error');

        let $radio_buttons = $(this).find('input:radio');
        let $check_boxes = $(this).find('input:checkbox');
        let $textareas = $(this).find('textarea');

        if ( $radio_buttons.exists() && !$radio_buttons.is(":checked") ) {
          $(this).addClass('error');
          submit = false;
        }

        if ( $check_boxes.exists() && !$check_boxes.is(":checked") ) {
          $(this).addClass('error');
          submit = false;
        }

        if ( $textareas.exists() && !$textareas.val() ) {
          $(this).addClass('error');
          submit = false;
        }

      });

      // Submit if no empty required Field
      if (submit) { $(".poll-form").submit(); }
      
    });

  }

  // Login Modal Opener for logged-out Users
  function loginForm() {
    $('input:radio, input:checkbox, textarea, .-save').on( "click", function( event ) {
      event.preventDefault();
      APP.controllers.application.loginModal.open();
    });
  }


  return {
    init: init
  }

  })();
