APP.controllers_loggedin.registrations = (function() {

    function init() {
      APP.components.addressInput();

      if ($(".register-personalInfo").exists()) {
        initRegistrationForm();
      }
    }

    function initRegistrationForm() {
      new jBox('Confirm', {
        addClass:'jBox',
        attach: $(".graetzl-select-link"),
        title: 'Wähle ' + $(".graetzl-select-link").data("homegraetzl"),
        content: $("#select-graetzl-modal-content"),
        trigger: 'click',
        closeOnEsc: true,
        closeOnClick: 'body',
        blockScroll: true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        cancelButton: 'Abbrechen',
        confirmButton: 'Übernehmen',
        confirm: function() {
          $(".form-register .graetzl-id-input").val($("#graetzl-select select").val());
          $(".register-personalInfo h1 span").text($("#graetzl-select select option:selected").text());
        },
      });

      $('input[name="user[business]"]').on("change", function() {
        var isBusiness = $('input[name="user[business]"]:checked').val() == '1';
        $(".user-business").toggle(isBusiness);
      }).change();

      $(".business-interests input").on("change", function() {
        if ($(".business-interests input:checked").length >= 6) {
          $(".business-interests input:not(:checked)").each(function() {
            $(this).prop("disabled", true);
            $(this).parents(".input-checkbox").addClass("disabled");
          });
        } else {
          $(".business-interests input").prop("disabled", false);
          $(".business-interests .input-checkbox").removeClass("disabled");
        }
      });
    }

    return {
        init: init
    }

})();
