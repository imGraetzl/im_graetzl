//= require jquery
//= require jquery.sumoselect

(function () {
  $(document).ready(function () {
    console.log('test');
    $('select.admin-filter-select').SumoSelect({
      search: true,
      csvDispCount: 5
    });
  });
})();
