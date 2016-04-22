(function() {
  $(document).ready(function() {

    function initDistrictCheckboxes() {
      var $districtCheckboxes = $('[data-behavior=district-checkbox]');
      if($districtCheckboxes.length) {
        setInitialState($districtCheckboxes);
        $districtCheckboxes.on('change', handleDistrictCheck);
      }
    }

    function initAllDistrictsCheckbox() {
      var $allDistrictsCheckbox = $('[data-behavior=all-districts-checkbox]');
      var $districtCheckboxes = $('[data-behavior=district-checkbox]');
      var $checked = $districtCheckboxes.filter(':checked');
      if ($allDistrictsCheckbox.length) {
        if($checked.length == $districtCheckboxes.length) {
          $allDistrictsCheckbox.prop('checked', true)
        } else {
          $allDistrictsCheckbox.prop('checked', false)
        }
        $allDistrictsCheckbox.on('change', handleAllDistrictsCheck);
      }
    }

    function handleDistrictCheck() {
      var checked = $(this).prop('checked')
      var $graetzlCheckBoxes = getGraetzlCheckboxes($(this))
      $graetzlCheckBoxes.prop('checked', checked)
    }

    function handleAllDistrictsCheck() {
      var checked = $(this).prop('checked');
      var $districtCheckboxes = $('[data-behavior=district-checkbox]');
      $districtCheckboxes.prop('checked', function() {
        getGraetzlCheckboxes($(this)).prop('checked', checked);
        return checked;
      });
    }

    function setInitialState(districtCheckboxes) {
      districtCheckboxes.each(function() {
        var $checkBoxes = getGraetzlCheckboxes($(this));
        var $checked = $checkBoxes.filter(':checked');
        if ($checked.length == $checkBoxes.length) {
          $(this).prop('checked', true);
        } else {
          $(this).prop('checked', false);
        }
      });
    }

    function getGraetzlCheckboxes(districtCheckbox) {
      var district = districtCheckbox.data('district');
      var selectorString = '[data-behavior=graetzl-checkbox][data-district=' + district + ']';
      return $(selectorString);
    }

    initDistrictCheckboxes();
    initAllDistrictsCheckbox();
  });
})();
