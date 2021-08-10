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

    // Activate Coop & Share
    if ( $("#flash .notice").text().indexOf('Dein Coop & Share Angebot ist nun aktiv') >= 0 ){
      gtag(
        'event', 'Coop & Share :: Click :: Status Aktiv', {
        'event_category': 'Coop & Share'
      });
    }

    // Deactivate Coop & Share
    if ( $("#flash .notice").text().indexOf('Dein Coop & Share Angebot ist nun deaktiviert') >= 0 ){
      gtag(
        'event', 'Coop & Share :: Click :: Status Inaktiv', {
        'event_category': 'Coop & Share'
      });
    }

    // Reactivate Coop & Share
    if ( $("#flash .notice").text().indexOf('Dein Coop & Share Angebot wurde erfolgreich verlängert!') >= 0 ){
      gtag(
        'event', 'Coop & Share :: Click :: E-Mail Aktivierungslink', {
        'event_category': 'Coop & Share'
      });
    }


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
    $('#custom-keywords').tagsInput({'defaultText':'Eigene Stichwörter (mit Komma getrennt) ..'});

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
      $("div[data-category='" + selected_category_id + "']").show(); // Show selected
    }



  }


  return {
    init: init
  }

  })();
