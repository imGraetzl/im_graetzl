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

    function showSpinner() {
      $('.autocomplete-loading-spinner').removeClass('-hidden');
    }

    function hideSpinner() {
      $('.autocomplete-loading-spinner').addClass('-hidden');
    }

  }

  return {
    init: init,
  }

})();
