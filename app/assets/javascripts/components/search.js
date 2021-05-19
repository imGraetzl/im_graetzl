APP.components.search = (function() {

  function init() {

    $input = $("[data-behavior='autocomplete']");

    // Nav Search Icon Click: Delete Value and set Focus to Field
    $(".nav-autocomplete-icon").on("click", function() {
      $input.val("");
      setTimeout(function(){ $input.focus() }, 100); // hack: only works after waiting
    });

    $input.on("input", function(){
      showSpinner();
    })

    // Easy Autocomplete Logic
    var options = {
      getValue:"name",
      url: function(phrase) {
        return "/search/autocomplete.json?q=" + phrase;
      },
      categories: [
        {
          listLocation: "meetings",
          header: "Events & Workshops"
        },
        {
          listLocation: "locations",
          header: "Anbieter & Locations"
        },
        {
          listLocation: "rooms",
          header: "Raumteiler"
        },
        {
          listLocation: "tool_offers",
          header: "Toolteiler"
        },
        {
          listLocation: "groups",
          header: "Gruppen"
        },
      ],
      list: {
        match: {enabled: true},
        maxNumberOfElements: 10,
        onChooseEvent:function() {
          var url = $input.getSelectedItemData().url
          $input.val("");
          document.location.href = url;
        },
        onLoadEvent:function() {
          addCategoryLinks();
        },
        onShowListEvent:function() {
          hideSpinner();
        },
        onHideListEvent:function() {
          hideSpinner();
        },
      },
      template: {
        type: "custom",
        method: function(value, item) {
          return "<div class='item " + item.type + " " + item.past_flag + "'><img src='" + item.icon + "'><div class='calendarSheet'><div class='day'>" + item.day + "</div><div class='month'>" + item.month + "</div></div><div class='txt'>" + value + "</div></div>";
        }
	    },
      highlightPhrase: false,
      requestDelay: 750
    }

    $input.easyAutocomplete(options);

    // HELPER FUNCTIONS -------------------

    function showSpinner() {
      $('.autocomplete-loading-spinner').removeClass('-hidden');
    }

    function hideSpinner() {
      $('.autocomplete-loading-spinner').addClass('-hidden');
    }

    function addCategoryLinks() {

      var search_phrase = $input.val();
      var type;

      // Find Categories and add Link
      $('.eac-category').each( function( index, element ) {

          switch($(this).text()) {
            case 'Raumteiler':
              type = 'rooms'
              break;
            case 'Toolteiler':
              type = 'tool_offers'
              break;
            case 'Events & Workshops':
              type = 'meetings'
              break;
            case 'Anbieter & Locations':
              type = 'locations'
              break;
            case 'Gruppen':
              type = 'groups'
              break;
            default:
              type = ''
          }

          var link = "<a href='/search?q="+search_phrase+"&search_type="+type+"'>mehr anzeigen</a>"
          $(this).append(link);

      });
    }

  }

  return {
    init: init,
  }

})();
