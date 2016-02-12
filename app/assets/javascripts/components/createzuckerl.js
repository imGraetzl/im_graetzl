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

        $descriptioninput.autogrow({ onInitialize: true });

        bindevents();
        updatetitle();
        updatedescription();
        showinitiative();


        //temp spaghetti
        $("[data-behavior=step1] .btn-primary").on("click", function() {

            $(".createzuckerl .col-l").append("<div class='loader'></div>")
            $("[data-behavior=step1]").hide();
            setTimeout(function() {
                $("[data-behavior=step2]").fadeIn();
                $(".loader").remove();
            },1200)


        });
        $(".zuckerledit").on("click", function() {
            $("[data-behavior=step1]").show();
            $("[data-behavior=step2]").hide();
        });


        $(".collapsibletrigger").on("click", function() {
            $(this).next().slideDown();
            $(this).remove();
        })

    }

    function bindevents() {
        $titleinput.on("keyup change", updatetitle);
        $descriptioninput.on("keyup change", updatedescription);
        $imageinput.on("change", updateimage);
        $initiativeselect.on("change", showinitiative);
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

    return {
        init: init
    }


})();
