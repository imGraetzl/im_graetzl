APP.components.formHelper = (function() {

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

  // MAX Chars Input Counter
  // add "data: { max_chars: 1500 }" to any text_area or input
  // add <span class="charsLeft"></span> after textarea
  $("[data-max-chars]").keyup(function() {
    var maxLength = $(this).data('max-chars');
    var lengthCount = $(this).val().length;
    var lengthLeft = maxLength-lengthCount;
    $(this).closest('div').css("position", "relative");
    $(this).closest('div').find('.charsLeft').text(lengthLeft);
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

  return {
    maxCategories: maxCategories,
    bbCodeHelp: bbCodeHelp,
  };

})();
