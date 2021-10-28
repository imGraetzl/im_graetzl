APP.controllers.tool_demands = (function() {

  function init() {
    if ($("section.tool-form").exists()) initToolDemandForm();
    if ($("section.tool-demand").exists()) { initToolDemand(); }
    if ($("#hide-contact-link").exists()) inithideContactLink();
  }

  function initToolDemand() {
    // Sidebar Button Click
    $('#requesttoolBtn').on('click', function(event){
      event.preventDefault();
      var href = $(this).attr('href');
      gtag(
        'event', 'Toolsuche :: Click :: Kontaktieren', {
        'event_category': 'Toolteiler',
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
        'event', 'Toolsuche :: Click :: Kontaktinformationen einblenden', {
        'event_category': 'Toolteiler'
      });
    });

  }


  function inithideContactLink(){
    $('#contact-infos-block').show();
    $('#show-contact-link').hide();
  }


  function initToolDemandForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    $("textarea").autogrow({ onInitialize: true });
    $('#custom-keywords').tagsInput({'defaultText':'Eigene Stichwörter (mit Komma getrennt) ...'});

    $('.period-switch').on('change', function() {
      var showPeriodFields = $(this).val() == "true";
      $('#usage-period-true').toggle(showPeriodFields);
      $('#usage-period-false').toggle(!showPeriodFields);
    })
    $('.period-switch:checked').trigger('change');

    var dateFrom;
    var dateTo;

    $('.tool-form').find(".date-from").pickadate({
      hiddenName: true,
      min: true,
      formatSubmit: 'yyyy-mm-dd',
      format: 'ddd, dd mmm, yyyy',
      onClose: function() {
        $(document.activeElement).blur();
      },
      onSet: function(context) {
        if (typeof context.select !== 'undefined') {
          dateFrom = new Date(context.select);
          set_usage_days(dateFrom, dateTo);
        }
      }
    });

    $('.tool-form').find(".date-to").pickadate({
      hiddenName: true,
      min: true,
      formatSubmit: 'yyyy-mm-dd',
      format: 'ddd, dd mmm, yyyy',
      onClose: function() {
        $(document.activeElement).blur();
      },
      onSet: function(context) {
        if (typeof context.select !== 'undefined') {
          dateTo = new Date(context.select);
          set_usage_days(dateFrom, dateTo);
        }
      }
    });

    function set_usage_days(dateFrom, dateTo) {
      var oneDay = 24 * 60 * 60 * 1000;
      var days = Math.round(Math.abs(dateFrom - dateTo) / oneDay) + 1;
      if (typeof dateFrom !== 'undefined' && typeof dateTo !== 'undefined') {
        $('#tool_demand_usage_days').val(days);
      }
    }

  }

  return {
    init: init
  }

  })();
