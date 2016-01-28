APP.components.createzuckerl = (function() {

    var $titleinput, $descriptioninput, $imageinput, $titlepreview,
        $descriptionpreview, $imagepreview, $initiativeselect,
        $step1btn;

    function init() {

        $titleinput = $("[data-behavior=titleinput]");
        $descriptioninput = $("[data-behavior=descriptioninput]");
        $imageinput = $("[data-behavior=imageinput]");
        $titlepreview = $("[data-behavior=titlepreview]");
        $descriptionpreview = $("[data-behavior=descriptionpreview]");
        $imagepreview = $("[data-behavior=imagepreview]");
        $initiativeselect = $("[data-behavior=initiativeselect]");
        $step1btn = $("[data-behavior=step1btn]");

        $descriptioninput.autogrow({ onInitialize: true });

        bindevents();
        updatetitle();
        updatedescription();
        showinitiative();
        handlebuttonmode();

    }

    function bindevents() {
        $titleinput.on("keyup change", updatetitle);
        $descriptioninput.on("keyup change", updatedescription);
        $imageinput.on("change", updateimage);
        $initiativeselect.on("change", showinitiative);
        $titleinput.add($descriptioninput).add($imageinput).on("keyup change", handlebuttonmode);
        $step1btn.on("click", confirmbooking("step2"));
        $("[data-behavior=stepbackbtn]").on("click", confirmbooking("step1"));

    }

    function updatetitle() {
        if ($titleinput.val()) $titlepreview.removeClass("placeholder").text($titleinput.val());
        else $titlepreview.addClass("placeholder").text("Titel des Angebots");
    }

    function updatedescription() {
        if ($descriptioninput.val()) $descriptionpreview.removeClass("placeholder").text($descriptioninput.val());
        else $descriptionpreview.addClass("placeholder").text("Beschreibung des Angebots");
    }

    function updateimage() {
        FileAPI.Image(this.files[0]).preview(300, 180).get(function (err, img){
            $imagepreview.empty().append(img);
        });
    }

    function showinitiative() {
        var index = $initiativeselect.prop('selectedIndex');
        $(".initiative-info").children().hide().eq(index).fadeIn();
    }

    function handlebuttonmode() {
        if(validatefields()) $step1btn.removeClass('-disabled');
        else $step1btn.addClass('-disabled', true);
    }

    function validatefields() {
        return ($titleinput.val() && $descriptioninput.val() && $imageinput.val());
    }

    function confirmbooking(mode) {
        return function() {
            if(mode == "step2") {
                $(".booking-block, .preview-block .form-block").hide();
                $(".confirmation-block").fadeIn();
            } else if(mode == "step1") {
                $(".booking-block, .preview-block .form-block").show();
                $(".confirmation-block").hide();
            }

        }
    }


    return {
        init: init
    }


})();
