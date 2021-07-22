APP.components.cardBoxFilter = (function() {

  var filterForm = $(".cards-filter");
  var cardGrid = $('.card-grid');
  var formXhr;
  var masonrySetup = false;
  var modals = []

  function init() {

    // ----------- EPU-to-EPU
    $("#meeting-categories").on("change", function(){
      $("#meeting_category_id").val('');
      submitForm();
      var label_item = $(this).find('option:selected').text();
      gtag(
        'event', 'SFS :: Category Select', {
        'event_category': 'Filter',
        'event_label': label_item
      });
    });

    // JBOX Standard Filter MODAL
    $(".filter-selection-text-jbox a").not( ".plain-link, .filter-modal-areas" ).each(function(index, value) {

        var modal = $(this).attr('href');
        var $attach = $('[href="'+modal+'"]');
        var $content = $(''+modal+'');
        var modal_type = 'Confirm';

        $content.hasClass('oneclick') ? modal_type = 'Modal' : modal_type = 'Confirm';

        modals[modal] = new jBox(modal_type, {
          addClass:'jBox',
          attach: $attach,
          getTitle: 'data-jbox-title',
          content: $content,
          trigger: 'click',
          closeOnEsc:true,
          closeOnClick:'body',
          blockScroll:true,
          animation:{open: 'zoomIn', close: 'zoomOut'},
          confirmButton: 'Filter anwenden',
          cancelButton: 'Abbrechen',
          confirm: function() {
            updateFilterInputs(this.content);
            updateFilterLabels(this.content);
            submitForm();
            gtag_tracking(this.content);
          }
        });
    });


    // JBOX District Filter MODAL
    var districtModal = new jBox('Confirm', {
      addClass:'jBox',
      attach: '.filter-modal-areas',
      getTitle: 'data-jbox-title',
      confirmButton: 'Anwenden',
      cancelButton: 'Zurücksetzen',
      content: $('.filter-modal-jbox-areas'),
      trigger: 'click',
      closeOnEsc:true,
      closeOnClick:'body',
      blockScroll:true,
      animation:{open: 'zoomIn', close: 'zoomOut'},
      confirm: function() {
        selectAllGraetzlsIn(this.content);
        updateFilterInputs(this.content);
        updateFilterLabels(this.content);
        submitForm();
        gtag_tracking(this.content);
      },
      cancel: function() {
        unSelectAllDistricts(this.content);
        selectAllGraetzlsIn(this.content);
        updateFilterInputs(this.content);
        updateFilterLabels(this.content);
        submitForm();
      }
    });


    // Activity Stream Graetzl District Modal Radios Select on Click
    $(".filter-area input").on("change", function(){
      $(".filter-area input").prop("checked", false);
      $(this).prop("checked", true);
    });



    $(".filter-modal-jbox-areas").on("click", "#select-home-graetzl", function() {
      selectHomeGraetzl();
    });


    // District Filter - Select Ganz Wien Checkbox
    $(".filter-modal-jbox-areas").on("click", ".select-all", function() {
      if ($(".select-all input:checkbox").prop('checked') == true) {
        selectAllDistricts($(".filter-modal-jbox-areas"));
        $('.filter-modal-jbox-areas #select-home-graetzl').prop("checked", false); // deselect HomeGraetzl
      } else {
        unSelectAllDistricts($(".filter-modal-jbox-areas"));
      }
    });


    // Toggle ganz Wien Checkbox wenn alle Bezirke gewählt
    $(".filter-modal-jbox-areas .filter-input").on("change", function() {

      $('.filter-modal-jbox-areas #select-home-graetzl').prop("checked", false); // deselect HomeGraetzl

      var countDistricts = $(".filter-modal-jbox-areas .filter-input").length;
      var countCheckedDistricts = $(".filter-modal-jbox-areas .filter-input").find('input:checked').length;

      if (countDistricts == countCheckedDistricts) {
        $(".select-all input:checkbox").prop("checked", true);
      } else {
        $(".select-all input:checkbox").prop("checked", false);
      }

    });


    // Use for OneClick Modals
    $(".filter-modal-jbox.oneclick .filter-input").on("change", function() {
      var currentModalContent = $(this).closest( ".filter-modal-jbox" );
      var currentModalId = '#' + currentModalContent.attr('id');
      updateFilterInputs(currentModalContent);
      updateFilterLabels(currentModalContent);
      submitForm();
      gtag_tracking(currentModalContent);
      modals[currentModalId].close();
    });


    // HELPER FUNCTIONS & INIT ------------

    // Update Filter Labels on Load
    $("[class^='filter-modal-']").each(function() {
      updateFilterLabels($(this));
    });


    $('.link-load').on('ajax:success', function() {
      removeDuplicateCards();
      adjustNewCards();
    });

    selectHomeGraetzl();
    submitForm();

  }


  // ---- AJAX FORM SUBMIT ----
  function submitForm() {

    var submit_url = filterForm.attr('action');
    var submit_params = filterForm.serialize();

    if (typeof formXhr !== 'undefined') {
        formXhr.abort();
    }

    formXhr = $.ajax({
        type: "GET",
        url: submit_url,
        data: submit_params,
        beforeSend: function(){
          clearandInitGrid();
          showSpinner();
        },
        success: function(){
          addActionCard();
          addFeaturedCard();
          adjustNewCards();
        }
    });

  }


  function selectHomeGraetzl() {
    if ($('#select-home-graetzl').prop('checked') == true) {
      unSelectAllDistricts($(".filter-modal-jbox-areas"));
      $('.filter-modal-jbox-areas #select-all').prop("checked", false); // deselect Wien
    }
  }


  function selectAllDistricts(modal) {
    modal.find(".filter-input input:checkbox").each(function(){
      $(this).prop("checked", true);
    });
  }


  function unSelectAllDistricts(modal) {
    modal.find(".filter-input input:checkbox").each(function(){
      $(this).prop("checked", false);
    });
  }


  function selectAllGraetzlsIn(modal) {

    var districtIds = [];
    modal.find(".filter-input input:checkbox:checked").each(function(){
      districtIds = districtIds.concat($(this).val());
    });

    if (districtIds.length == 23) {
      unSelectAllDistricts(modal);
      districtIds = []; // Reset for better Rails Performance
    }

    $('.graetzl-ids').find('option').each(function() {
      $(this).prop("selected", false);
      var inSelectedDistrict = districtIds && districtIds.indexOf($(this).data('districtId').toString()) > -1;
      if (inSelectedDistrict) $(this).prop("selected", true);
    });

    var $homeGraetzl = modal.find('#select-home-graetzl'); // Set Home Graetzl
    if ($homeGraetzl.prop('checked') == true) {
      $('.graetzl-ids').val($homeGraetzl.val());
    }

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

    var allInputsCount = modal.find(".filter-input").length;
    var selectedInputs = modal.find(".filter-input :selected, .filter-input :checked");
    var link = filterForm.find('a[href="#' + modal.prop("id") + '"]');

    if (modal.find(".filter-input select").data("select-all")) {
      link.text(link.data("no-filter-label"));
      link.removeClass('filter-applied');

    } else if (modal.find('#select-home-graetzl').prop('checked') == true) {
        link.text(modal.find('#select-home-graetzl').data('label'));
        link.addClass('filter-applied');

    } else if (selectedInputs.length == allInputsCount) {
        link.text(link.data("no-filter-label"));
        link.removeClass('filter-applied');

    } else if (selectedInputs.length > 2) {
        var selectedCount = selectedInputs.length;
        var shownCount = selectedInputs.length - 2;
        selectedInputs.length = 2; // Cut for too much labels and show more info
        var label = selectedInputs.map(function() { return $(this).data("label"); }).get().join(", ");
        link.text(label +', + ' + shownCount + ' weitere');
        link.addClass('filter-applied');

    } else if (selectedInputs.length > 0) {
        var label = selectedInputs.map(function() { return $(this).data("label"); }).get().join(", ");
        link.text(label);
        link.addClass('filter-applied');

    } else {
        link.text(link.data("no-filter-label"));
        link.removeClass('filter-applied');
    }

    // ----- Select Label in SidebarBox if Exists
    if ($('.updateFromFilter').exists()) {
      selectedInputsID = selectedInputs.attr('id');
      $('.updateFromFilter li').removeClass("active");
      var matchedLabel = $('.updateFromFilter').find('[data-id='+selectedInputsID+']');
      matchedLabel.closest("li").addClass("active");
      // Set Browser Address Bar:
      var matchedLabelId = matchedLabel.data('cat-id');
      if (typeof matchedLabelId == 'number'){
        history && history.pushState({}, '', location.pathname + '?category=' + matchedLabelId);
      }
      else {
        history && history.replaceState({}, '', location.pathname);
      }
    }


  }


  function gtag_tracking(modal) {

    var label_category = "Filter";
    var label_type = modal.find("[data-filter-label]").data("filter-label");
    var label_item = filterForm.find('a[href="#' + modal.prop("id") + '"]').text();

    if ( typeof modal.data("category-label") !== "undefined") {
      label_category = modal.data("category-label");
    }
    gtag(
      'event', label_type + ' :: Modal', {
      'event_category': label_category,
      'event_label': label_item
    });
  }


  function clearandInitGrid() {

    var allItems = cardGrid.find('[data-behavior="masonry-card"]');
    allItems.remove();
    $('.link-load').addClass("hide");

    if ( masonrySetup ) { cardGrid.masonry("destroy"); }

    cardGrid.masonry({
      columnWidth: 310,
      gutter: 24,
      itemSelector: '[data-behavior="masonry-card"]',
      fitWidth : true,
      horizontalOrder: true
    });
    masonrySetup = true;

  }


  function showSpinner() {
    var spinner = $('footer .loading-spinner').clone().removeClass('-hidden');
    if (!cardGrid.find('.loading-spinner').exists()) {
      cardGrid.html(spinner);
    }
  }


  function addActionCard() {
    if ($(".action-card-container").exists()) {
      var actionCard = $(".action-card-container").children().first().clone();
      if (cardGrid.children(":eq(1)").exists()) {
        cardGrid.children(":eq(1)").after(actionCard);
      } else {
        cardGrid.append(actionCard);
      }
    }
  }


  function addFeaturedCard() {
    if ($('.featuredCard').exists()) {
      var featuredCard = $('.featuredCard').clone().removeClass('-hidden');
      if (cardGrid.children(':eq(2)').exists()) {
        cardGrid.children(':eq(2)').after(featuredCard);
      }
    }
  }


  function initInfiniteScroll() {
    var btn_link_load_clicked = false;
    $(window).scroll(function() {
      // Click Btn on bottom Scroll via JS if Btn & more Data exists (is not hidden)
      if (cardGrid.exists() && !$('.link-load').hasClass('hide')) {
        var scrollTop = $(document).scrollTop();
        var windowHeight = $(window).height();
        var height = $(document).height() - windowHeight;
        var scrollPercentage = (scrollTop / height);

        // if the scroll is more than 70% from the top, load more content.
        if(scrollPercentage > 0.7 && btn_link_load_clicked == false) {
          $('.link-load').click();
          btn_link_load_clicked = true;
        }
      }
    });
  }


  function removeDuplicateCards() {
    var items = cardGrid.find('[data-card-id]');
    var exists = {};
    console.log(items.length);
    items.each(function() {
        var cardId = $(this).attr('data-card-id');
        if (exists[cardId]) {
          console.log($(this));
          $(this).remove();
        } else {
          exists[cardId] = true;
        }
    });
  }


  function adjustNewCards() {
    var newCards = cardGrid.find('[data-behavior="masonry-card"]').not('[data-appended]');
    cardGrid.masonry('appended', newCards);
    newCards.attr("data-appended", true);
    APP.components.initUserTooltip();
    initInfiniteScroll();
  }


  return {
    init: init,
    submitForm : submitForm,
    updateFilterLabels : updateFilterLabels,
    showSpinner : showSpinner,
    gtag_tracking : gtag_tracking
  };

})();
