//= require jquery.autocomplete

APP.components.addressInput = function() {

  var container = $(".address-autocomplete");
  if (container.length == 0) return;

  container.find('.address-autocomplete-input').autocomplete({
    minChars: 3,
    deferRequestBy: 100,
    appendTo: container,
    forceFixPosition: true,
    lookupLimit: 10,
    lookup: searchAddress,
    onSelect: selectAddress,
  });

  function selectAddress(suggestion) {
    if (suggestion) {
      container.find(".address-zip-input").val(suggestion.data.zip);
      container.find(".address-city-input").val(suggestion.data.city);
      if (suggestion.data.coordinates) {
        container.find(".address-coords-input").val(suggestion.data.coordinates.join(","));
      }
      container.find(".address-graetzl-input").val(suggestion.data.graetzl_id);
    } else {
      container.find(".address-coords-input").val(null);
    }
  }

  function searchAddress(query, done) {
    $.get(container.data("url"), { q: query }, function(data) {
      done({ suggestions: data });
    });
  }

};
