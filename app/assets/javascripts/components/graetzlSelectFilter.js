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

    if ($districtSelect.val().length > 0) {
      showDistrictGraetzls($districtSelect.val());
    }

    $graetzlSelect.SumoSelect({
      search: true,
      searchText: 'Suche nach Grätzln.',
      placeholder: 'Grätzln auswählen',
      csvDispCount: 3,
      captionFormat: '{0} Grätzln ausgewählt'
    });

    $districtSelect.on('change', function() {
      var districtIds = $districtSelect.val();
      if (districtIds && districtIds.indexOf('deselect-all') > -1) {
        $districtSelect[0].sumo.unSelectAll();
        $districtSelect[0].sumo.hideOpts();
      } else {
        showDistrictGraetzls(districtIds);
        deselectGraetzlsNotIn(districtIds);

        var newSelection = $(districtIds).not(selectedDistrictIds).get();
        selectAllGraetzlsIn(newSelection);

        selectedDistrictIds = districtIds;
        $graetzlSelect[0].sumo.reload();
      }
    } );

    function showDistrictGraetzls(districtIds) {
      $graetzlSelect.find('option').each(function() {
        var inSelectedDistrict = districtIds && districtIds.indexOf($(this).data('districtId').toString()) > -1;
        $(this).prop('disabled', !inSelectedDistrict);
      });
    }

    function deselectGraetzlsNotIn(districtIds) {
      $graetzlSelect.find('option').each(function() {
        var inSelectedDistrict = districtIds && districtIds.indexOf($(this).data('districtId').toString()) > -1;
        if (!inSelectedDistrict) $(this).prop("selected", false);
      });
    }

    function selectAllGraetzlsIn(districtIds) {
      $graetzlSelect.find('option').each(function() {
        var inSelectedDistrict = districtIds && districtIds.indexOf($(this).data('districtId').toString()) > -1;
        if (inSelectedDistrict) $(this).prop("selected", true);
      });
    }
  }

  return {
    init: init
  };
})();
