APP.controllers.contact_list_entries = (function() {

    function init() {
        if($(".form-block").exists()) initForm();
    }

    function initForm() {
        if($("#error_explanation").exists()) {
          $('html, body').animate({
            scrollTop: $('#error_explanation').offset().top
          }, 600);
        }
    }

    return {
      init: init
    };

})();
