APP.components.graetzlSelectFilter = function() {

    var select = $("select.district-graetzl-filter")
    select.SumoSelect({
        search: true,
        searchText: 'Suche nach Bezirk.',
        placeholder: 'Bezirk auswählen',
        csvDispCount: 5,
        captionFormat: '{0} Bezirk ausgewählt'
    });
    select.on('change', function() {
        var districtID = $(this).val();
        console.log('DISTRICT SELECT', districtID);
        $('input#room_demand_district_ids_' + districtID).attr('checked', true);
    });

    var select2 = $("select.graetzl-filter")
    select2.SumoSelect({
        search: true,
        searchText: 'Suche nach Grätzln.',
        placeholder: 'Grätzln auswählen',
        csvDispCount: 5,
        captionFormat: '{0} Grätzln ausgewählt'
    });
    select2.on('change', function() {
        var graetzlID = $(this).val();
        console.log('GRAETZL SELECT', graetzlID);
        $('input#room_demand_graetzl_ids_' + graetzlID).attr('checked', true);
    });
};
