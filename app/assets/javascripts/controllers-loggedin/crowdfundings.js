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

      $('.using-address-switch').on('change', function() {
        var noAddress = $(this).val() == "true";
        $('#not-using-address-fields').toggle(noAddress);
        $('#using-address-fields').toggle(!noAddress);
        $("#using-address-fields").find("input, select").attr("disabled", noAddress);
      });
      $('.using-address-switch:checked').trigger('change');

      $('.datepicker').pickadate({
        formatSubmit: 'yyyy-mm-dd',
        format: 'dddd, dd mmm, yyyy',
        hiddenName: true,
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
        APP.components.formHelper.maxCategories($(this).parents(".cb-columns"), 1); // init on Change
      }).trigger('change');


      // video modal
      if ($(window).width() < 800) {
        // adjust iframe height on smaller screens
        var iframe = document.getElementById("videoIframe");
        var iframeHeight = $(window).width() * 0.56;
        iframe.style.height = iframeHeight + 'px';
      }

      var videoModal = new jBox('Modal', {
        addClass:'jBox jBoxVideo',
        attach: '#jBoxVideo',
        content: $('#jBoxVideoContent'),
        trigger: 'click',
        closeOnEsc:true,
        closeOnClick:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        onClose: function () {
          var vidsrc = $('#videoIframe').attr('src');
          $('#videoIframe').attr('src','');
          $('#videoIframe').attr('src', vidsrc);
        }
      });

    }

    return {
      init: init
    };

})();
