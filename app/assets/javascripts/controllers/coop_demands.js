APP.controllers.coop_demands = (function() {

  function init() {
    if ($("section.coop-demand-form").exists()) initCoopDemandForm();
    if ($("section.coop-demand").exists()) { initCoopDemand(); }
    if ($("#hide-contact-link").exists()) inithideContactLink();
  }

  function initCoopDemand() {
    // Sidebar Button Click
    $('#requestCoopDemandBtn').on('click', function(event){
      event.preventDefault();
      var href = $(this).attr('href');
      gtag(
        'event', 'Coop & Share :: Click :: Kontaktieren', {
        'event_category': 'Coop & Share',
        'event_callback': function() {
          location.href = href;
        }
      });
    });

    $('#contact-infos-block').hide();
    $('#show-contact-link').on('click', function(event){
      event.preventDefault();
      $('#contact-infos-block').fadeIn();
      $(this).hide();
      gtag(
        'event', 'Coop & Share :: Click :: Kontaktinformationen einblenden', {
        'event_category': 'Coop & Share'
      });
    });

  }


  function inithideContactLink(){
    $('#contact-infos-block').show();
    $('#show-contact-link').hide();
  }


  function initCoopDemandForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    $("textarea").autogrow({ onInitialize: true });
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
      $radio = $('.category-switch').find("label:contains('Verein')").closest('.input-radio');
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
