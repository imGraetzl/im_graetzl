APP.controllers_loggedin.crowd_campaigns = (function() {

    function init() {
        if ($("section.crowd_campaign").exists()) initCrowdCampaign();
        if ($("section.crowdfunding-form").exists()) initCrowdfundingForm();
        if ($("section.crowdfunding-form.noteditable").exists()) initNoEditMode();
    }

    function initCrowdCampaign() {
      $('.crowd_campaign .-compose-mail').on("click", function(event) {
        event.preventDefault();
        if($("#tab-compose-mail").is(":hidden")){
          APP.components.tabs.openTab('compose-mail');
        }
        $('html, body').animate({
          scrollTop: $('#tab-compose-mail').offset().top
        }, 600);
      });
    }

    function initNoEditMode() {
      $(".crowd-categories, .benefit-checkbox").find("input").each(function() {
        $(this).prop("disabled", true);
        $(this).parents(".input-checkbox").addClass("disabled");
      });
    }

    function initComposeMail() {
      $('select#mail-user-select').SumoSelect({
        search: true,
        searchText: 'Suche nach Unterstützer*in',
        placeholder: 'Unterstützer*in auswählen',
        csvDispCount: 2,
        captionFormat: '{0} Unterstützer*innen',
        captionFormatAllSelected: 'Alle Unterstützer*innen',
        selectAll: true,
        isClickAwayOk: true,
        okCancelInMulti: true,
        locale: ['Auswählen', 'Abbrechen', 'Alle auswählen']
      });
    }

    function initCrowdfundingForm() {

      APP.components.districtGraetzlInput();
      APP.components.addressInput();
      APP.components.formValidation.init();
      APP.components.search.userAutocomplete();
      APP.components.tabs.initTabs(".tabs-ctrl");
      APP.components.formHelper.bbCodeHelp();
      APP.components.formHelper.maxChars();
      APP.components.formHelper.savingBtn();

      $('.crowdfunding-form').find(':disabled').closest("div[class^='input-']").addClass('disabled');

      $('input[name="crowd_campaign[benefit]"]').on("change", function() {
        if ($(this).is(':checked')) {
          $(".benefit-fields").show();
          $('textarea').autoheight();
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

      $('.table-container .toggle').on("click", function(event) {
        $(this).closest('.flex-table').find('.toggle-cell').slideToggle();
      });

      function initNestedOpener() {
        $('.-toggle input').on("focus", function(event) {
          nestedOpener($(this));
        });
        $('.-toggle.disabled').on("click", function(event) {
          nestedOpener($(this));
        });
      }

      function nestedOpener(elem) {

        if (!$(elem).closest('.nested-fields').find('.-toggle').hasClass("-opened")) {
          var $content = $(elem).closest('.nested-fields').find('.toggle-content');
          var $opener = $(elem).closest('.nested-fields').find('.-toggle');
          $content.slideDown(function(){
            if($content.is(":visible")){
              $opener.addClass('-opened');
              $('textarea').autoheight();
              APP.components.fileUpload.init();
              APP.components.formHelper.maxChars();
            }
            else {
              $opener.removeClass('-opened');
            }
          });
        }
        return false;
      }

      $('.crowdfunding-form').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
        $('.datepicker').pickadate({
          formatSubmit: 'yyyy-mm-dd',
          hiddenName: true,
          min: true
        });

        initNestedOpener();
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
        onClose: function() {
          window.location.reload(); // Needed to prevent double nested form entries
        },
      });

      // Slider Input Range
      if ($(".input-range").exists()) {

        const slider = document.getElementById("percentage");
        const listItems = document.querySelectorAll(".range ul.editable li");

        listItems.forEach(li => {
            li.addEventListener("click", function() {
                const value = this.getAttribute("data-value");
                slider.value = value;
                // Slider Event auslösen
                slider.dispatchEvent(new Event("input"));
            });
        });

        const blockElement = document.querySelector(".percentage-block");
        const sliderElement = document.querySelector("#percentage");
        const sliderURL = sliderElement.getAttribute('data-url');
        const disabled = sliderElement.getAttribute('disabled');
        const sliderValuesAttr = sliderElement.getAttribute('data-percentage-values');
        const percentageValues = sliderValuesAttr ? sliderValuesAttr.split(',').map(value => parseFloat(value)) : [];
        const sliderMin = parseInt(sliderElement.getAttribute('min'), 10) || 0;
        const sliderMax = parseInt(sliderElement.getAttribute('max'), 10) || (percentageValues.length ? percentageValues.length - 1 : 5);
        const rangeSpan = sliderMax - sliderMin > 0 ? sliderMax - sliderMin : 1;

        let sliderColor = "#EC776A";
        if (disabled) {
          sliderColor = "#aaaaaa";
        }

        sliderElement.addEventListener("input", (event) => {
            const tempSliderValue = parseInt(event.target.value, 10); 
            blockElement.setAttribute('data-percent', tempSliderValue);
            const progress = ((tempSliderValue - sliderMin) / rangeSpan) * 100;
            sliderElement.style.background = `linear-gradient(to right, ${sliderColor} ${progress}%, #f0f0f0 ${progress}%)`;
            percentageConverter(tempSliderValue);
            savePercentage(tempSliderValue);
        })

        function percentageForIndex(index) {
          if (!percentageValues.length) {
            return index;
          }
          return percentageValues[index] || percentageValues[0];
        }

        function percentageConverter(value) {
          const index = parseInt(value, 10);
          $("[class^='percent']").removeClass('-show');
          $(".percent-"+index).addClass('-show');
          return percentageForIndex(index);
        }

        function savePercentage(value) {
          const index = parseInt(value, 10);
          const percentage = percentageForIndex(index);
          $.ajax({
            url: sliderURL,
            dataType: "json",
            type: "POST",
            data: { percentage: percentage },
            success: function(response) {
              //console.log(response);
            }
           });
        }

        function initSlider() {
            const currentValue = parseInt(sliderElement.value, 10);
            const sliderValue = ((currentValue - sliderMin) / rangeSpan) * 100;
            sliderElement.style.background = `linear-gradient(to right, ${sliderColor} ${sliderValue}%, #f0f0f0 ${sliderValue}%)`;
            percentageConverter(sliderElement.value);
        }
        initSlider();
      }

    }

    return {
      init: init,
      initComposeMail: initComposeMail
    };

})();
