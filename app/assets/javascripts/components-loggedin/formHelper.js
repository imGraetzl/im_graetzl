APP.components.formHelper = (function() {

  // Safari Fix: Disable Submit Button onClick (rails disable_with not working) and Submit Form robust
  function savingBtn() {
    $('.-saving-legacy').on('click', function(event){
      var $btn = $(this);
      var btnDisabledText = $btn.data('disable-with');
      if (!btnDisabledText) {
        return;
      }
      var $form = $btn.closest('form');

      // Validierung (optional)
      let valid = true;
      $form.find('[required]').each(function() {
        if ($(this).is(':invalid') || !$(this).val()) valid = false;
      });
      if (!valid) return;

      // Button deaktivieren und Text ändern
      $btn.prop('disabled', true);
      $btn.text(btnDisabledText);

      // Optional: Button-Name als Hidden Field
      if ($btn[0].name && $btn[0].value) {
        $('<input>').attr({ type: 'hidden', name: $btn[0].name, value: $btn[0].value}).appendTo($form);
      }

      // Standard-Submit verhindern und manuell submitten (Safari-Fix!)
      event.preventDefault();
      $form.submit();
    });
  }

  function maxCategories(container, max) {
    if (container.find("input:checked").length >= max) {
      container.find("input:not(:checked)").each(function() {
        $(this).prop("disabled", true);
        $(this).parents(".input-checkbox").addClass("disabled");
      });
    } else {
      container.find("input").prop("disabled", false);
      container.find(".input-checkbox").removeClass("disabled");
    }
  }

  function maxChars() {
    // MAX Chars Input Counter
    // add "data: { max_chars: 1500 }" to any text_area or input
    // add <span class="charsLeft"></span> after textarea
    $("[data-max-chars]").keyup(function() {
      var maxLength = $(this).data('max-chars');
      var lengthCount = $(this).val().length;
      var newLines = $(this).val().match(/(\r\n|\n|\r)/g);
      var additional = newLines?.length || 0;
      var lengthLeft = maxLength-lengthCount;
      $(this).closest('div').css("position", "relative");
      $(this).closest('div').find('.charsLeft').text(lengthLeft);
      $(this).attr('maxlength', maxLength + additional);
    });

    // MIN Chars Input Counter
    // add "data: { min_chars: 1500 }" to any text_area or input
    // add <span class="charsCount"></span> ... after textarea
    $("[data-min-chars]").keyup(function() {
      var minLength = $(this).data('min-chars');
      var lengthCount = $(this).val().length;
      $(this).closest('div').css("position", "relative");
      $(this).closest('div').find('.charsCount').text(lengthCount);
      $(this).closest('div').find('.charsMin').text("(mind. " + minLength + " Zeichen)");
    });
  }

  function bbCodeHelp() {

    $(".bbcodeField label").click(function(e) {
      e.preventDefault();
    });

    $(".bbcodeField textarea").focus(function() {
      $(this).closest('div').find('.bbCodeOpener').show();
    });

    $(".bbcodeField textarea").blur(function() {
      $(this).closest('div').find('.bbCodeOpener').delay(100).fadeOut();
    });

    var bbCodeHelp = new jBox('Modal', {
      attach: '.bbCodeOpener',
      addClass:'jBox',
      content: $('#bbCodeHelp'),
      closeOnEsc:true,
      closeOnClick:'body',
      animation:{open: 'zoomIn', close: 'zoomOut'},
      onClose: function() {
        this.source.closest('div').find('textarea').focus();
      }
    });
  }

  function formatIBAN() {
    $(".iban").on("input", function(e) { insertSpaces(this) }); // Init on Input
    $(".iban").each(function() { insertSpaces(this) }); // Init on Load
  }

  function insertSpaces($iban) {
    $iban.value = $iban.value.replace(/[^\dA-Za-z0-9]/g, '').replace(/(.{4})/g, '$1  ').trim().toUpperCase();
  }

  return {
    maxCategories: maxCategories,
    maxChars: maxChars,
    bbCodeHelp: bbCodeHelp,
    savingBtn: savingBtn,
    formatIBAN: formatIBAN,
  };

})();
