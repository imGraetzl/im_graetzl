//= require jquery.autocomplete

APP.components.addressInput = function() {

  var container = $(".address-autocomplete");
  if (container.length == 0) return;

  container.find('.address-autocomplete-input').autocomplete({
    minChars: 3,
    deferRequestBy: 200,
    appendTo: container,
    forceFixPosition: true,
    lookupLimit: 10,
    serviceUrl: container.data("url"),
    formatResult: formatAddress,
    onSearchComplete: checkResults,
    triggerSelectOnValidInput: true,
    onSelect: selectAddress,
  });

  container.find('.address-autocomplete-input').on("input", function() {
    if ($(this).val().length < 3) {
      container.find(".address-coords-input").val(null);
      container.find('.address-autocomplete-input').removeClass("confirmed");
    }
  });

  function formatAddress(suggestion, currentValue) {
    var optionHtml = $.Autocomplete.defaults.formatResult(suggestion, currentValue);
    if (suggestion.data.graetzl_name) {
      optionHtml += '<span>' + suggestion.data.graetzl_name + '</span>';
    }
    return optionHtml;
  }

  function checkResults(_query, suggestions) {
    if (suggestions.length == 0) {
      container.find(".address-coords-input").val(null);
      container.find('.address-autocomplete-input').removeClass("confirmed");
    }
  }

  function selectAddress(suggestion) {
    container.find(".address-zip-input").val(suggestion.data.zip);
    container.find(".address-city-input").val(suggestion.data.city);
    container.find(".address-coords-input").val(suggestion.data.coordinates.join(","));
    container.find(".address-graetzl-input").val(suggestion.data.graetzl_id);
    container.find('.address-autocomplete-input').addClass("confirmed");
  }
};
