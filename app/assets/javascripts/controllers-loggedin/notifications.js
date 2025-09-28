APP.controllers_loggedin.notifications = (function() {

  function init() {
    if ($("section.notification-container").exists()) initAdminNotifications();
  }

  function initAdminNotifications() {
    APP.components.cardBoxFilter.init();

    const regionRadios = document.querySelectorAll("#filter-modal-region input[type='radio']");
    const graetzlFilter = document.querySelector(".region_graetzl_filter");

    function updateFilter() {
      const selectedRadio = document.querySelector("#filter-modal-region input[type='radio']:checked");

      if (selectedRadio && selectedRadio.value === "wien") {
        graetzlFilter.classList.remove("-hidden");
      } else {
        graetzlFilter.classList.add("-hidden");

        // Alle Checkboxen in .filter-areas abwählen
        $('#filter-modal-areas').closest('.jBox-container').find('.jBox-Confirm-button-cancel').click();
      }
    }

    // Event-Listener für Änderungen an den Radio-Buttons
    regionRadios.forEach(radio => {
      radio.addEventListener("change", updateFilter);
    });

    // Beim Laden der Seite den initialen Zustand setzen
    updateFilter();

  }

  function filterOwner(owner_id) {
    let $input = $('input[name="filter[owner_id]"]');
    $input.val(owner_id);
    $(".notification-owner-wrp").show();
    APP.components.cardBoxFilter.submitForm();
  }

  $('.notification-owner-wrp').on('click', function(event){
    $('input[name="filter[owner_id]"]').val('');
    $(this).hide();
    APP.components.cardBoxFilter.submitForm();
  });

  return {
    init: init,
    filterOwner: filterOwner
  }

})();
