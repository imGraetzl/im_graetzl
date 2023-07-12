APP.components.graetzlSelectFilter = (function() {

  var selectedDistrictIds = [];

  function init(container) {
    var region = container.data('region') || 'Wien';
    var graetzl = container.data('graetzl') || 'Grätzl';
    var $districtSelect = container.find(".district-select");
    var $graetzlSelect = container.find(".graetzl-select");
    var $resetButton = container.find(".reset-button");

    $districtSelect.SumoSelect({
      search: true,
      searchText: 'Suche nach Bezirk...',
      placeholder: 'Bezirk auswählen',
      csvDispCount: 3,
      captionFormat: '{0} Bezirke',
      captionFormatAllSelected: 'Alle {0} Bezirke in ' + region,
      okCancelInMulti: true,
      selectAll: true,
      locale: ['Übernehmen', 'Abbrechen', 'Ganz ' + region]
    });

    if ($districtSelect.val() && $districtSelect.val().length > 0) {
      showDistrictGraetzls($districtSelect.val());
    }

    $graetzlSelect.SumoSelect({
      search: true,
      searchText: 'Suche nach ' + graetzl + '...',
      placeholder: graetzl + ' auswählen',
      csvDispCount: 3,
      captionFormat: '{0} ' + graetzl + '',
      captionFormatAllSelected: 'Alle {0} '+ graetzl +'n in ' + region,
      okCancelInMulti: true,
      locale: ['Übernehmen', 'Abbrechen']
    });

    // Init Districts of Selected Graetzls (michael)
    showGraetzlDistricts($graetzlSelect.find(':selected').map(function() {
      if ($(this).data('districtId')) return $(this).data('districtId').toString();
    }));

    $districtSelect.on('change', function() {
      var districtIds = $districtSelect.val();
      showDistrictGraetzls(districtIds);
      deselectGraetzlsNotIn(districtIds);

      var newSelection = $(districtIds).not(selectedDistrictIds).get();
      selectAllGraetzlsIn(newSelection);

      selectedDistrictIds = districtIds;
      $graetzlSelect[0].sumo.reload();

      if ($districtSelect.find("option:not(:selected)").length == 0) {
        $districtSelect.data("select-all", true);
      } else {
        $districtSelect.data("select-all", false);
      }
    });

    $resetButton.on('click', function() {
      $districtSelect[0].sumo.unSelectAll();
      $graetzlSelect[0].sumo.unSelectAll();
      container.find(".filter-button").click();
    });

    function showDistrictGraetzls(districtIds) {
      $graetzlSelect.find('option').each(function() {
        var inSelectedDistrict = districtIds && districtIds.indexOf($(this).data('districtId').toString()) > -1;
        $(this).prop('disabled', !inSelectedDistrict);
      });
    }

    // select districts function (Michael)
    function showGraetzlDistricts(districtIds) {
      var districtIds = Array.from(districtIds);
      $.each(districtIds, function( index, value ) {
        $districtSelect[0].sumo.selectItem(value);
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
