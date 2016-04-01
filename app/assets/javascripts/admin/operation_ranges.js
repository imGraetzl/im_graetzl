(function() {
  $(document).ready(function() {

    function initDistrictCheckboxes() {
      var $districtCheckboxes = $('[data-behavior=district-checkbox]');
      if($districtCheckboxes.length) {
        setInitialState($districtCheckboxes);
        $districtCheckboxes.on('change', handleDistrictCheck);
      }
    }

    function handleDistrictCheck() {
      var $graetzlCheckBoxes = getGraetzlCheckboxes($(this));
      if($graetzlCheckBoxes.prop('checked')) {
        $graetzlCheckBoxes.prop('checked', false);
      } else {
        $graetzlCheckBoxes.prop('checked', true);
      }
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
  });
})();
