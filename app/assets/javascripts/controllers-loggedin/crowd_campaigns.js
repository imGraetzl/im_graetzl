APP.controllers_loggedin.crowd_campaigns = (function() {

    function init() {
        if ($("section.crowdfunding-form").exists()) initCrowdfundingForm();
        if ($("section.crowdfunding-form.noteditable").exists()) initNoEditMode();
    }

    function initNoEditMode() {
      $(".crowd-categories, .benefit-checkbox").find("input").each(function() {
        $(this).prop("disabled", true);
        $(this).parents(".input-checkbox").addClass("disabled");
      });
    }

    function initCrowdfundingForm() {

      APP.components.districtGraetzlInput();
      APP.components.addressInput();
      APP.components.formValidation.init();
      APP.components.search.userAutocomplete();

      $("textarea").autoResize();

      $('.crowdfunding-form').find(':disabled').closest("div[class^='input-']").addClass('disabled');

      $('input[name="crowd_campaign[benefit]"]').on("change", function() {
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
            if ($('input[name="crowd_campaign[enddate]"]').val() == '') {
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

      function nestedOpener() {
        $('.-toggle input').on("focus", function(event) {
          if (!$(this).closest('.nested-fields').find('.-toggle').hasClass("-opened")) {
            var $content = $(this).closest('.nested-fields').find('.toggle-content');
            var $opener = $(this).closest('.nested-fields').find('.-toggle');
            $content.slideDown(function(){
              if($content.is(":visible")){$opener.addClass('-opened');}
              else {$opener.removeClass('-opened');}
            });
          }
          return false;
        });
      }

      $('.crowdfunding-form').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
        $('.datepicker').pickadate({
          formatSubmit: 'yyyy-mm-dd',
          hiddenName: true,
          min: true
        });

        nestedOpener();
        $(insertedItem).find('.-toggle input').focus();

      }).trigger('cocoon:after-insert');

      // max categories
      $(".crowd-categories input").on("change", function() {
        APP.components.formHelper.maxCategories($(this).parents(".cb-columns"), 3); // init on Change
      }).trigger('change');

      // Preview Project  - Save Form and Open Preview Modal
      $(".save-and-preview").on("click", function() {
        var form = $(".crowdfunding_form");
        var submit_url = form.attr('action');
        var submit_params = form.serialize();

        if (typeof formXhr !== 'undefined') { formXhr.abort(); }

        formXhr = $.ajax({
            type: "POST",
            url: submit_url,
            data: submit_params,
            success: function(){
              previewModal.open();
            }
        });
      });

      // PreviewModal and ModalPreviewSize
      var iframewidth = $(window).width() + 'px';
      var iframeheight = $(window).height() - 100 + 'px';
      if($(window).width() > 1050) {
        var iframewidth = '1050px';
      }
      var previewModal = new jBox('Modal', {
        addClass:'jBox jBoxCrowdPreview',
        content: $('#cf-preview'),
        closeOnEsc:true,
        closeOnClick:true,
        blockScroll:true,
        isolateScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        onOpen: function() {
          var iframe = document.getElementById("cfpreview");
          iframe.src = $("#cfpreview").data('url');
          iframe.style.width = iframewidth;
          iframe.style.height = iframeheight;
        },
      });

    }

    return {
      init: init
    };

})();
