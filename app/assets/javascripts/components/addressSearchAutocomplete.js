//= require typeahead.bundle

APP.components.addressSearchAutocomplete = function() {
  var region = $('body').data('region');
  var container = $("#addressSearchAutocomplete");
  if (container.length == 0) return;

  if (region == 'wien') {
    var SEARCH_URL = 'https://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?crs=EPSG:4326&Address=';
  } else {
    var SEARCH_URL = 'http://api.opendata.host/1.0/address/find?country=at&offset=1&limit=100&street-address=';
  }

  var addressSearch = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 7,
    remote: {
      url: SEARCH_URL + '%QUERY',
      filter: function(response) {
        selectAddress(response.features[0]);
        return response.features;
      },
      /*
      ajax: {
            beforeSend: function(jqXHR, settings) {
               jqXHR.setRequestHeader("Access-Control-Allow-Credentials", 'true');
               jqXHR.setRequestHeader('Authorization', 'Basic ' + btoa('9D46-38C6-31CF-40E9-BBBF-AFF6-37A3-D7C7:'));
           }
       }
       */
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
