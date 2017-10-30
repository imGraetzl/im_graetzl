APP.components.graetzlSelectFilter = function() {

    var select = $("select.district-graetzl-filter")
    select.SumoSelect({
        search: true,
        searchText: 'Enter here.',
        placeholder: 'Bezirk oder Grätzl schreiben',
        csvDispCount: 5,
        captionFormat: '{0} Kategorien ausgewählt'
    });
    select.on('change', function() {
        var districtID = $(this).val();
        console.log('DISTRICT SELECT', districtID);
        $('input#room_demand_district_ids_' + districtID).attr('checked', true);
        // var url = '/wien/' + districtID + '/graetzls';
        // //var graetzlSelect = $('select#graetzl_id');
        // var graetzlSelect = $('select.graetzl_id');
        //
        // $.ajax({
        //     url: url,
        //     dataType: 'json',
        //     type: 'GET',
        //     beforeSend: function() {
        //         console.log('BEFORE SEND');
        //         graetzlSelect.prop('disabled', 'disabled');
        //     },
        //     success: function(data, textStatus, jqXHR) {
        //         console.log('SUCCESS');
        //         graetzlSelect.prop('disabled', false);
        //         update_options(graetzlSelect, data);
        //     },
        //     error: function(jqXHR, textStatus,errorThrown) {
        //         console.log('ERROR');
        //         graetzlSelect.prop('disabled', false);
        //     }
        // });
        //
        // function update_options(select, data) {
        //     select.empty()
        //     data.forEach(function(obj) {
        //         select.append($('<option></option>')
        //             .attr('value', obj.id)
        //             .text(obj.name));
        //     });
        // }
    });

};
