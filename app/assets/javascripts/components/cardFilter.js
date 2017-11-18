APP.components.cardFilter = (function() {

  var filterForm;

  function init() {
    filterForm = $(".cards-filter");

    filterForm.find(".filter-selection-text a").featherlight({
      targetAttr: 'href',
      persist: true
    });

    $(".filter-modal").on("click", ".filter-button", function() {
      var currentModal = $.featherlight.current();
      updateFilterInputs(currentModal.$content);
      updateFilterLabels(currentModal.$content);
      filterForm.submit();
      currentModal.close();
    });

    $(".filter-modal").each(function() {
      updateFilterInputs($(this));
    });
    
    var grid = APP.components.masonryFilterGrid;

    filterForm.on('ajax:success', function() {
      grid.initGrid();
    });

    $('.link-load').on('ajax:success', function() {
      grid.adjustNewCards();
    });

    filterForm.submit();
  }

  function updateFilterInputs(modal) {
    filterForm.find('[id^="' + modal.prop("id") + '"]').remove();
    modal.find("input, select").each(function() {
      var cloneId = modal.prop("id") + "_" + ($(this).prop("id") || $(this).prop("name"));
      // We need to copy the value manually because clone() doesn't do it for select elements
      $(this).clone().prop("id", cloneId).val($(this).val()).appendTo(filterForm).hide();
    });
  }

  function updateFilterLabels(modal) {
    var selectedInputs = modal.find(".filter-input :selected, .filter-input :checked");
    var link = filterForm.find('a[href="#' + modal.prop("id") + '"]');
    if (selectedInputs.length > 0) {
      var label = selectedInputs.map(function() { return $(this).data("label"); }).get().join(", ");
      link.text(label);
    } else {
      link.text(link.data("no-filter-label"));
    }
  }

  return {
    init: init
  };
})();
