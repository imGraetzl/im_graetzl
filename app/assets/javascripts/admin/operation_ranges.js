(function() {
  $(document).ready(function() {
    var $districtCheckboxes = $('[data-behavior=district-checkbox]')
    var $allDistrictsCheckbox = $('[data-behavior=all-districts-checkbox]')

    function initCheckboxes() {
      if ($districtCheckboxes.length && $allDistrictsCheckbox.length) {
        initDistrictCheckboxes()
        initAllDistrictsCheckbox()
      }
    }

    function initDistrictCheckboxes() {
      $districtCheckboxes.each(function() {
        var $checkBoxes = getGraetzlCheckboxes($(this))
        var $checked = $checkBoxes.filter(':checked')
        var allChecked = ($checked.length == $checkBoxes.length)
        $(this).prop('checked', allChecked)
      });
      $districtCheckboxes.on('change', handleDistrictCheck)
    }

    function initAllDistrictsCheckbox() {
      var $checked = $districtCheckboxes.filter(':checked')
      var allChecked = ($checked.length == $districtCheckboxes.length)
      $allDistrictsCheckbox.prop('checked', allChecked)
      $allDistrictsCheckbox.on('change', handleAllDistrictsCheck)
    }

    function handleDistrictCheck() {
      var checked = $(this).prop('checked')
      var $graetzlCheckBoxes = getGraetzlCheckboxes($(this))
      $graetzlCheckBoxes.prop('checked', checked)
    }

    function handleAllDistrictsCheck() {
      var checked = $(this).prop('checked')
      $districtCheckboxes.prop('checked', function() {
        getGraetzlCheckboxes($(this)).prop('checked', checked)
        return checked
      });
    }

    function getGraetzlCheckboxes(districtCheckbox) {
      var district = districtCheckbox.data('district')
      var selectorString = '[data-behavior=graetzl-checkbox][data-district=' + district + ']'
      return $(selectorString)
    }

    initCheckboxes()
  });
})();
