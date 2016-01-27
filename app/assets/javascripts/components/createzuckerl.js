APP.components.createzuckerl = (function() {

    var $titleinput, $descriptioninput, $imageinput, $titlepreview, $descriptionpreview, $imagepreview;

    function init() {
        $titleinput = $("[data-behavior=titleinput]");
        $descriptioninput = $("[data-behavior=descriptioninput]");
        $imageinput = $("[data-behavior=imageinput]");
        $titlepreview = $("[data-behavior=titlepreview]");
        $descriptionpreview = $("[data-behavior=descriptionpreview]");
        $imagepreview = $("[data-behavior=imagepreview]");

        $descriptioninput.autogrow({ onInitialize: true });
        bindevents();
        updatetitle();
        updatedescription();
    }

    function bindevents() {
        $titleinput.on("keyup change", updatetitle);
        $descriptioninput.on("keyup change", updatedescription);
        $imageinput.on("change", updateimage);
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
        $imagepreview.empty();
        FileAPI.Image(this.files[0]).preview(300, 180).get(function (err, img){
            $imagepreview.append(img);
        });
    }


    return {
        init: init
    }


})();
