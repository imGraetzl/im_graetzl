//= require jquery.sumoselect

(function () {
  $(document).ready(function () {
    $('select.admin-filter-select').SumoSelect({
      search: true,
      csvDispCount: 5
    });
  });
})();
