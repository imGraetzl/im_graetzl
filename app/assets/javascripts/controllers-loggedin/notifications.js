APP.controllers_loggedin.notifications = (function() {

  function init() {
    if ($("section.notification-container").exists()) initAdminNotifications();
  }

  function initAdminNotifications() {
    APP.components.cardBoxFilter.init();

    const regionRadios = document.querySelectorAll("#filter-modal-region input[type='radio']");
    const graetzlFilter = document.querySelector(".region_graetzl_filter");
    const filterAreaCheckboxes = document.querySelectorAll(".filter-areas input[type='checkbox']");

    function updateFilter() {
      const selectedRadio = document.querySelector("#filter-modal-region input[type='radio']:checked");

      if (selectedRadio && selectedRadio.value === "wien") {
        graetzlFilter.classList.remove("-hidden");
      } else {
        graetzlFilter.classList.add("-hidden");

        // Alle Checkboxen in .filter-areas abwählen
        $('#filter-modal-areas').closest('.jBox-container').find('.jBox-Confirm-button-cancel').click();
        //$('#filter-modal-type input#filter_type_').prop('checked', true).trigger('change');
      }
    }

    // Event-Listener für Änderungen an den Radio-Buttons
    regionRadios.forEach(radio => {
      radio.addEventListener("change", updateFilter);
    });

    // Beim Laden der Seite den initialen Zustand setzen
    updateFilter();

  }

  return {
    init: init
  }

})();
