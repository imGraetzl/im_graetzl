//= require typeahead.bundle

APP.components.addressSearchAutocomplete = function() {

  var region = $('body').data('region');
  var container = $("#addressSearchAutocomplete");
  if (container.length == 0) return;

  if (region == 'kaernten') {
    var SEARCH_URL = 'https://api.mapbox.com/geocoding/v5/mapbox.places/';
    var SEARCH_PARAMS = '.json?access_token=pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw&autocomplete=true&country=at&limit=10&types=address&language=de&bbox=14.452515,46.607469,14.987411,46.845634';
  } else if (region == 'muehlviertler-kernland') {
    var SEARCH_URL = 'https://api.mapbox.com/geocoding/v5/mapbox.places/';
    var SEARCH_PARAMS = '.json?access_token=pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw&autocomplete=true&country=at&limit=10&types=address&language=de&bbox=14.364624,48.279537,14.740906,48.650150';
  } else {
    var SEARCH_URL = 'https://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?crs=EPSG:4326&Address=';
    var SEARCH_PARAMS = '';
  }

  var addressSearch = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: region == 'kaernten' || 'muehlviertler-kernland' ? 10 : 7,
    remote: {
      url: SEARCH_URL + '%QUERY' + SEARCH_PARAMS,
      filter: function(response) {
        // Filter Response for Gemeinden we have.
        if (region == 'kaernten') {
          response.features = response.features.filter(function(element) {
            return element.context[1].text_de.includes('Griffen') ||
            element.context[1].text_de.includes('St. Andrä') ||
            element.context[1].text_de.includes('Völkermarkt')
          });
        } else if (region == 'muehlviertler-kernland') {
          response.features = response.features.filter(function(element) {
            return element.context[1].text_de.includes('Kefermarkt') ||
            element.context[1].text_de.includes('Hirschbach') ||
            element.context[1].text_de.includes('Windhaag') ||
            element.context[1].text_de.includes('Grünbach') ||
            element.context[1].text_de.includes('Oswald') ||
            element.context[1].text_de.includes('Pregarten') ||
            element.context[1].text_de.includes('Unterweitersdorf') ||
            element.context[1].text_de.includes('Freistadt') ||
            element.context[1].text_de.includes('Tragwein') ||
            element.context[1].text_de.includes('Sandl') ||
            element.context[1].text_de.includes('Lasberg') ||
            element.context[1].text_de.includes('Leopoldschlag') ||
            element.context[1].text_de.includes('Hagenberg') ||
            element.context[1].text_de.includes('Gutau')
          });
        }
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
      if (region == 'kaernten' || region == 'muehlviertler-kernland') {
        return data.place_name_de;
      } else {
        return data.properties.Adresse;
      }
    },
    templates: {
      suggestion: function(data) {
        if (region == 'kaernten' || region == 'muehlviertler-kernland') {
          return data.place_name_de.split(',')[0] +'<span class="district">' + data.context[0].text_de + ' ' + data.context[1].text_de + '</span>';
        } else {
          return data.properties.Adresse +'<span class="district">Bezirk: ' + data.properties.Bezirk + '</span>';
        }
      }
    }
  }).on('typeahead:selected typeahead:autocompleted', function(event, suggestion) {
    selectAddress(suggestion);
  });

  function selectAddress(obj) {
    container.find("[name=feature]").val(JSON.stringify(obj));
  }

};
