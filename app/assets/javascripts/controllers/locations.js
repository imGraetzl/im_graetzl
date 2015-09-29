APP.controllers.locations = (function() {

    function init() {

        APP.components.addressSearchAutocomplete();

        $('select.categories').SumoSelect({
            placeholder: 'Wähle einen oder mehreren Kategorien',
            csvDispCount: 5,
            captionFormat: '{0} Kategorien ausgewählt'
        });

        // tryout
        $('select#district_id').on('change', function() {
            console.log('DISTRICT SELECT');
            var districtID = $(this).val();
            var url = '/wien/' + districtID + '/graetzls';
            var graetzlSelect = $('select#graetzl_id');

            $.ajax({
                url: url,
                dataType: 'json',
                type: 'GET',
                beforeSend: function() {
                    console.log('BEFORE SEND');
                    graetzlSelect.prop('disabled', 'disabled');
                },
                success: function(data, textStatus, jqXHR) {
                    console.log('SUCCESS');
                    graetzlSelect.prop('disabled', false);
                    update_options(graetzlSelect, data);
                },
                error: function(jqXHR, textStatus,errorThrown) {
                    console.log('ERROR');
                    graetzlSelect.prop('disabled', false);
                }
            });


            function update_options(select, data) {
                select.empty()
                data.forEach(function(obj) {
                    select.append($('<option></option>')
                        .attr('value', obj.id)
                        .text(obj.name));
                });
            }
        });

    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();