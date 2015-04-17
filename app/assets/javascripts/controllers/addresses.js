APP.controllers.addresses = (function() {

    function init() {

        addressSearchAutocomplete();

    }

// ---------------------------------------------------------------------- Custom

    function addressSearchAutocomplete() {

        var addressSearch = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            limit: 7,
            remote: {
                url:  APP.config.adressSearchOpenGov + '%QUERY',
                filter: function(addresses) {
                    console.log(addresses.features);
                    // Map the remote source JSON array to a JavaScript object array
                    return $.map(addresses.features, function (address) {
                        return {
                            value: {
                                street: address.properties.Adresse,
                                district: address.properties.Bezirk
                            }
                        };
                    });
                }
            }
        });

        addressSearch.initialize();

        $('#address').typeahead(null, {
            name: 'addresse',
            source: addressSearch.ttAdapter(),
            displayKey: function (data) {
                return data.value.street;
            },
            templates: {
                suggestion: function(data) {
                    return data.value.street +'<span class="district">' + data.value.district + '</span>'
                }
            }
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();