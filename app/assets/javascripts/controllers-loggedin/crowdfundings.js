APP.controllers_loggedin.crowdfundings = (function() {

    function init() {
        if ($("section.crowdfunding-form").exists()) initCrowdfundingForm();
    }

    function initCrowdfundingForm() {

      APP.components.formValidation.init();
      APP.components.districtGraetzlInput();
      APP.components.addressInput();
      APP.components.search.userAutocomplete();

      $("textarea").autoResize();

      $('input[name="crowdfunding[benefit]"]').on("change", function() {
        if ($(this).is(':checked')) {
          $(".benefit-fields").show();
        }
        else {
          $(".benefit-fields").hide();
        }
      }).change();

      $('.startdate').pickadate({
        formatSubmit: 'yyyy-mm-dd',
        format: 'ddd, dd mmm, yyyy',
        hiddenName: true,
        min: true,
        onSet: function(context) {
          if (typeof context.select !== 'undefined') {
            var mindate = new Date(context.select);
            var maxdate = new Date(context.select);
            mindate.setDate(mindate.getDate() + 14); // Minimum 14 Days after Startdate
            maxdate.setMonth(maxdate.getMonth() + 2); // Maximum 2 Months after Startdate
            $('.enddate').pickadate('picker').set('min', mindate);
            $('.enddate').pickadate('picker').set('max', maxdate);
            if ($('input[name="crowdfunding[enddate]"]').val() == '') {
              var enddate = new Date(context.select);
              enddate.setMonth(enddate.getMonth() + 1);
              $('.enddate').pickadate('picker').set('select', enddate); // Default 1 Monath after Startdate
            }
          }
        },
      });

      $('.enddate').pickadate({
        formatSubmit: 'yyyy-mm-dd',
        format: 'ddd, dd mmm, yyyy',
        hiddenName: true,
        min: 15,
      });

      $('.crowdfunding-form').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
        $('.datepicker').pickadate({
          formatSubmit: 'yyyy-mm-dd',
          hiddenName: true,
          min: true
        });
      }).trigger('cocoon:after-insert');

      // max categories
      $(".crowd-categories input").on("change", function() {
        APP.components.formHelper.maxCategories($(this).parents(".cb-columns"), 3); // init on Change
      }).trigger('change');

    }

    return {
      init: init
    };

})();
