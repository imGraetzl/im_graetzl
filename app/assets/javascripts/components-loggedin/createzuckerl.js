APP.components.createzuckerl = (function() {
    var $titleinput, $descriptioninput, $imageinput, $districtinput, $titlepreview,
        $descriptionpreview, $imagepreview, $pricepreview, $btnconfirm, $btnsend,
        $graetzlpreview, $alldistrictspreview;

    function init() {

        $titleinput = $("[data-behavior=titleinput]");
        $descriptioninput = $("[data-behavior=descriptioninput]");
        $linkinput = $("[data-behavior=linkinput]");
        $imageinput = $(".direct-upload-result");
        $districtinput = $('.district_visibility .input-radio');
        $titlepreview = $("[data-behavior=titlepreview]");
        $linkpreview = $("a.linkpreview");
        $descriptionpreview = $("[data-behavior=descriptionpreview]");
        $pricepreview = $("[data-behavior=pricepreview]");
        $graetzlpreview = $("[data-behavior=graetzlpreview]");
        $alldistrictspreview = $("[data-behavior=alldistrictspreview]");
        $imagepreview = $("[data-behavior=imagepreview]");
        $btnconfirm = $("[data-behavior=btn-confirm]");
        $btnsend = $("[data-behavior=btn-send]");

        //$descriptioninput.autoResize();

        bindevents();
        updatetitle();
        updatedescription();
        updatelink();
        updatedistricts();
        btnclickability();
        disabledistricts();
        $linkpreview.hide();
    }

    function bindevents() {
        $titleinput.on("keyup change", updatetitle);
        $descriptioninput.on("keyup change", updatedescription);
        $linkinput.on("keyup change", updatelink);
        $imageinput.on("upload:complete", function() { setTimeout(updateimage, 300) });
        $districtinput.on("change", updatedistricts);
        $btnconfirm.on("click", btnstate);
        $("[data-behavior=zuckerlform]").on("submit", submitzuckerlform);
        $titleinput.add($descriptioninput).on("keyup change", function() {
            btnclickability();
            btnstate("reset");
        });
    }

    function disabledistricts() {
        $('.-edit .district_visibility input:radio').attr('disabled',true);
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
      var selected_input = $(".district_visibility input[type='radio']:checked");
      $pricepreview.text(formatPrice(selected_input.data("price")));

      if (selected_input.data('behavior') == "entire_region_true") {
        $('.description .graetzl').hide();
        $('.description .entire_region').show();
        $graetzlpreview.hide();
        $alldistrictspreview.show();
      } else {
        $('.description .entire_region').hide();
        $('.description .graetzl').show();
        $alldistrictspreview.hide();
        $graetzlpreview.show();
      }
    }

    function updateimage() {
      var src = $(".upload-preview-image").attr("src");
      $imagepreview.html($("<img>").attr("src", src));
      btnclickability();
      btnstate("reset");
    }

    function validatefields() {
        return ($titleinput.val().length > 0 && $descriptioninput.val().length > 0 && $imageinput.val().length > 0);
    }

    function btnclickability() {
        if(validatefields()) $btnconfirm.removeClass('-disabled');
        else $btnconfirm.addClass('-disabled', true);
    }

    function submitzuckerlform(e) {
        if($btnsend.exists() && !$btnsend.hasClass("is-visible")) {
            e.preventDefault();
        }
    }

    function btnstate(mode) {
        if(mode === "reset") {
            $btnconfirm.show();
            $btnsend.removeClass("is-visible");
        } else {
            $btnconfirm.hide();
            $btnsend.addClass("is-visible");
        }
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
