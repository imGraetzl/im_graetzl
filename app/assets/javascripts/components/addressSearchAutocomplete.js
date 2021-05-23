//= require typeahead.bundle

APP.components.addressSearchAutocomplete = function() {
  var container = $("#addressSearchAutocomplete");
  if (container.length == 0) return;

  var SEARCH_URL = 'https://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?crs=EPSG:4326&Address=';
  var addressSearch = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 7,
    remote: {
      url: SEARCH_URL + '%QUERY',
      filter: function(response) {
        selectAddress(response.features[0]);
        return response.features;
      }
    }
  });
  addressSearch.initialize();

  container.find("[name=address], .address-input").typeahead(null, {
    name: 'addresse',
    source: addressSearch.ttAdapter(),
    displayKey: function(data) {
      return data.properties.Adresse;
    },
    templates: {
      suggestion: function(data) {
        return data.properties.Adresse +'<span class="district">Bezirk: ' + data.properties.Bezirk + '</span>';
      }
    }
  }).on('typeahead:selected typeahead:autocompleted', function(event, suggestion) {
    selectAddress(suggestion);
  });

  function selectAddress(obj) {
    container.find("[name=feature]").val(JSON.stringify(obj));
  }

};
