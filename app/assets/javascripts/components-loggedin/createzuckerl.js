APP.components.createzuckerl = (function() {

    var $titleinput = $("[data-behavior=titleinput]");
    var $descriptioninput = $("[data-behavior=descriptioninput]");
    var $linkinput = $("[data-behavior=linkinput]");
    var $imageinput = $(".direct-upload-result");
    var $districtinput = $('#area-select select');
    var $titlepreview = $("[data-behavior=titlepreview]");
    var $linkpreview = $("a.linkpreview");
    var $descriptionpreview = $("[data-behavior=descriptionpreview]");
    var $pricepreview = $("[data-behavior=pricepreview]");
    var $oldpricepreview = $("[data-behavior=oldpricepreview]");
    var $graetzlpreview = $("[data-behavior=graetzlpreview]");
    var $runtimepreview = $("[data-behavior=runtimepreview]");
    var $imagepreview = $("[data-behavior=imagepreview]");
    var $gratzl_visibility = $("[data-behavior=gratzl_visibility]");

    function init() {

        bindevents();
        updatetitle();
        updatedescription();
        updatelink();
        updatedistricts();
        toggleAvatarBlock();
        toggleDistrictDropdown();

        $('.starts_at').pickadate({
          formatSubmit: 'yyyy-mm-dd',
          format: 'd. mmm, yyyy',
          hiddenName: true,
          min: 1,
          max: 365,
          onSet: function(context) {
            if (typeof context.select !== 'undefined') {
              var startDate = new Date(context.select);
              var endDate = new Date(context.select);
              endDate.setMonth(endDate.getMonth() + 1);
              endDate.setDate(endDate.getDate() - 1);
              $('.ends_at').pickadate('picker').set('select', endDate); // 1 Month after Startdate

              // Formatieren der Anzeige als "05. Mär – 04. Apr, 2025"
              var startFormatted = formatPickadate(startDate);
              var endFormatted = formatPickadate(endDate);

              // Setzt die Anzeige für den Zeitraum
              $runtimepreview.text(startFormatted + ' – ' + endFormatted);

            }
          },
          onClose: function() {
            $(document.activeElement).blur();
          },
        });
  
        $('.ends_at').pickadate({
          formatSubmit: 'yyyy-mm-dd',
          format: 'd. mmm, yyyy',
          hiddenName: true,
        });

        document.querySelector('.location-selector').addEventListener('change', toggleAvatarBlock);

    }

    function toggleAvatarBlock() {
      // Alle Location-Divs ausblenden
      document.querySelectorAll('.avatar-block').forEach(div => div.classList.add('-hide'));

      // Die ausgewählte Location holen
      var selectedLocation = document.querySelector('.location-selector').value;

      // Falls eine Location ausgewählt ist, die passende Div einblenden
      if (selectedLocation) {
        var targetDiv = document.getElementById('location_' + selectedLocation);
        if (targetDiv) {
          targetDiv.classList.remove('-hide');
        }
      } else {
        document.getElementById('user-avatar-block').classList.remove('-hide');
      }
    }

    function formatPickadate(date) {
      var options = { day: '2-digit', month: 'short', year: 'numeric' };
      return date.toLocaleDateString('de-DE', options).replace('.', '');
    }

    function bindevents() {
        $titleinput.on("keyup change", updatetitle);
        $descriptioninput.on("keyup change", updatedescription);
        $linkinput.on("keyup change", updatelink);
        $imageinput.on("upload:complete", function() { setTimeout(updateimage, 300) });
        $districtinput.on("change", updatedistricts);
        $(document).on('change', 'input[name="zuckerl[entire_region]"]', function() {
          toggleDistrictDropdown();
          updatedistricts();
        });
    }

    function updatetitle() {
        if ($titleinput.val()) $titlepreview.removeClass("placeholder").text($titleinput.val());
        else $titlepreview.addClass("placeholder").text("Titel des Angebots");
    }

    function updatedescription() {
        if ($descriptioninput.val()) $descriptionpreview.removeClass("placeholder").text($descriptioninput.val());
        else $descriptionpreview.addClass("placeholder").text("Beschreibung des Angebots");
    }

    function updatelink() {
        if ($linkinput.val()) {
          $linkpreview.attr("data-behavior", $linkinput.val());
          $linkpreview.show();
        }
        else {
          $linkpreview.hide();
        }
    }

    function updatedistricts() {
      var isEntireRegion = $('input[name="zuckerl[entire_region]"]:checked').val() === "true";
      var $selected_radio = $('input[name="zuckerl[entire_region]"]:checked');
      var $selected_option = $districtinput.find('option:selected');

      if (isEntireRegion) {
        var radioId = $selected_radio.attr('id');
        var radioLabelText = $('label[for="' + radioId + '"]').text();

        $pricepreview.text(formatPrice($selected_radio.data("price")));
        $gratzl_visibility.text($selected_radio.data("label"));
        $graetzlpreview.text(radioLabelText);
        if ($selected_radio.data("old-price")) {
          $oldpricepreview.text('(statt ' + formatPrice($selected_radio.data("old-price")) + ')');
        } else {
          $oldpricepreview.text('');
        }
        $('.description .entire_region').show();
        $('.description .graetzl').hide();
      } else {
        $pricepreview.text(formatPrice($selected_option.data("price")));
        $gratzl_visibility.text($selected_option.data("label"));
        $graetzlpreview.text($selected_option.text());
        if ($selected_option.data("old-price")) {
          $oldpricepreview.text('(statt ' + formatPrice($selected_option.data("old-price")) + ')');
        } else {
          $oldpricepreview.text('');
        }
        $('.description .entire_region').hide();
        $('.description .graetzl').show();
      }
    }

    function toggleDistrictDropdown() {
      var isEntireRegion = $('input[name="zuckerl[entire_region]"]:checked').val() === "true";
      var $dropdownWrapper = $('.district-select-wrapper');

      if (isEntireRegion) {
        $dropdownWrapper.addClass('-hidden');
      } else {
        $dropdownWrapper.removeClass('-hidden');
      }
    }

    function updateimage() {
      var src = $(".upload-preview-image").attr("src");
      $imagepreview.html($("<img>").attr("src", src));
    }

    function formatPrice(price) {
      return '€' + (price / 100).toFixed(2);
    }

    $("a.linkpreview").on('click', function(){
      var link = $("a.linkpreview").attr("data-behavior");
      if (!link.match(/^[a-zA-Z]+:\/\//)) {
          link = 'http://' + link;
      }
      window.open(link, '_blank');
    });


    return {
        init: init
    }


})();
