APP.components.graetzlSelect = function() {

    $('select#district_id').on('change', function() {
        var districtID = $(this).val();
        var url = $(this).data("url") + "?district_id=" + districtID;
        var graetzlSelect = $('select.graetzl_id');

        $.ajax({
            url: url,
            dataType: 'json',
            type: 'GET',
            beforeSend: function() {
                graetzlSelect.prop('disabled', 'disabled');
            },
            success: function(data, textStatus, jqXHR) {
                graetzlSelect.prop('disabled', false);
                update_options(graetzlSelect, data);
            },
            error: function(jqXHR, textStatus,errorThrown) {
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

};
