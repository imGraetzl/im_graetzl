APP.components.graetzlSelectFilter = (function() {

  var selectedDistrictIds = [];

  function init($districtSelect, $graetzlSelect) {
    $districtSelect.SumoSelect({
      search: true,
      searchText: 'Suche nach Bezirk.',
      placeholder: 'Bezirk auswählen',
      csvDispCount: 3,
      captionFormat: '{0} Bezirk ausgewählt'
    });

    $graetzlSelect.SumoSelect({
      search: true,
      searchText: 'Suche nach Grätzln.',
      placeholder: 'Grätzln auswählen',
      csvDispCount:   3,
      captionFormat: '{0} Grätzln ausgewählt'
    });

    $districtSelect.on('change', function() {
      var districtIds = $districtSelect.val();
      var newSelection = $(districtIds).not(selectedDistrictIds).get()[0];
      selectedDistrictIds = districtIds;

      $graetzlSelect.find('option').each(function() {
        var inSelectedDistrict = districtIds && districtIds.indexOf($(this).data('districtId').toString()) > -1;
        $(this).prop('disabled', !inSelectedDistrict);
        if (newSelection == $(this).data('districtId')) $(this).prop("selected", true);
        if (!inSelectedDistrict) $(this).prop("selected", false);
      });
      $graetzlSelect[0].sumo.reload();
    });
  }

  return {
    init: init
  };
})();
