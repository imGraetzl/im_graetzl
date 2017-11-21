APP.components.cardFilter = (function() {

  var filterForm;
  var cardGrid;
  var masonrySetup = false;

  function init() {
    filterForm = $(".cards-filter");
    cardGrid = $('.card-grid');

    filterForm.find(".filter-selection-text a").featherlight({
      root: '.card-grid-container',
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

    filterForm.on('ajax:success', function() {
      initGrid();
    });

    $('.link-load').on('ajax:success', function() {
      adjustNewCards();
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
      link.addClass('filter-applied');
    } else {
      link.text(link.data("no-filter-label"));
      link.removeClass('filter-applied');
    }
  }

  function initGrid() {
    if (masonrySetup) {
      cardGrid.masonry("destroy");
      masonrySetup = false;
    }

    if ($(".action-card-container").exists()) {
      var actionCard = $(".action-card-container").children().first().clone();
      if (cardGrid.children(":eq(1)").exists()) {
        cardGrid.children(":eq(1)").after(actionCard);
      } else {
        cardGrid.append(actionCard);
      }
    }

    cardGrid.imagesLoaded(function() {
      cardGrid.masonry({
        itemSelector: '[data-behavior="masonry-card"]',
        fitWidth : true
      });
    });

    masonrySetup = true;
  }

  function adjustNewCards() {
    cardGrid.masonry('appended', $('[data-behavior="masonry-card"]').not('[style]'));
  }

  return {
    init: init
  };
})();
