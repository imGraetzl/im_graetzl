APP.controllers_loggedin.coop_demands = (function() {

  function init() {
    if ($("section.coop-demand-form").exists()) initCoopDemandForm();
  }

  function initCoopDemandForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    $('#custom-keywords').tagsInput({'defaultText':'Eigene Stichwörter (mit Komma getrennt) ...'});

    $('.coop-category-switch').on("change", function() {
      var selected_category_id = $(this).val();
      $('.suggested-tags').hide(); // First hide all
      $("div[data-category='" + selected_category_id + "']").show(); // Show selected
      $(".suggested-tags:hidden input:checkbox").each(function(){
        $(this).prop("checked", false); // disable all hidden checkboxes
      });
    });

    if ($('.coop-category-switch:checked').length > 0) {
      var selected_category_id = $('.coop-category-switch:checked').val();
      $(".coop-tag-area").show();
      $("div[data-category='" + selected_category_id + "']").show(); // Show selected
    }

    if ($("form#new_coop_demand").exists()) {
      $('.coop-category-switch').on("change", function() {
        $('.coop-tag-area').slideDown();
      });
    }

    // Hide Radio "Vereine Category" bei Type "Biete"
    $('.coop-type-selection input').on('change', function() {
      $radio = $('.category-switch').find("label:contains('Mitglieder')").closest('.input-radio');
      if ($(this).val() == 'offer' & $(this).is(":checked")) {
        $radio.hide();
      } else {
        $radio.show();
      }
    }).trigger('change');

  }

  return {
    init: init
  }

  })();
