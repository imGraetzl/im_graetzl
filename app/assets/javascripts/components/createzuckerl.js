APP.components.createzuckerl = (function() {

    var $titleinput, $descriptioninput, $imageinput, $titlepreview,
        $descriptionpreview, $imagepreview, $initiativeselect,
        $btnconfirm, $btnsend;

    function init() {

        $titleinput = $("[data-behavior=titleinput]");
        $descriptioninput = $("[data-behavior=descriptioninput]");
        $imageinput = $("[data-behavior=imageinput]");
        $titlepreview = $("[data-behavior=titlepreview]");
        $descriptionpreview = $("[data-behavior=descriptionpreview]");
        $imagepreview = $("[data-behavior=imagepreview]");
        $initiativeselect = $("[data-behavior=initiativeselect]");
        $btnconfirm = $("[data-behavior=btn-confirm]");
        $btnsend = $("[data-behavior=btn-send]");

        $descriptioninput.autogrow({ onInitialize: true });

        bindevents();
        updatetitle();
        updatedescription();
        showinitiative();
        btnclickability();

    }

    function bindevents() {
        $titleinput.on("keyup change", updatetitle);
        $descriptioninput.on("keyup change", updatedescription);
        $imageinput.on("upload:complete", updateimage);
        $initiativeselect.on("change", showinitiative);
        $btnconfirm.on("click", btnstate);
        $("[data-behavior=zuckerlform]").on("submit", submitzuckerlform);
        $(".collapsibletrigger").on("click", showbillingform);
        $titleinput.add($descriptioninput).add($imageinput).on("keyup change", function() {
            btnclickability();
            btnstate("reset");
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

    function updateimage() {
        FileAPI.Image(this.files[0]).preview(300, 180).get(function (err, img){
            $imagepreview.empty().append(img);
        });
    }

    function showinitiative() {
        var index = $initiativeselect.prop('selectedIndex');
        $(".initiative-info").children().hide().eq(index).fadeIn();
    }

    function validatefields() {
        return ($titleinput.val().length > 0 && $descriptioninput.val().length > 0 && $imageinput.val().length > 0);
    }

    function btnclickability() {
        if(validatefields()) $btnconfirm.removeClass('-disabled');
        else $btnconfirm.addClass('-disabled', true);
    }

    function submitzuckerlform(e) {
        if(!$btnsend.hasClass("is-visible")) {
            e.preventDefault();
        }
        // } else {
        //     //TODO: temporary to simulate 2nd step, we can remove this in final version ----------------------------------------------<
        //     $(".billing-block").fadeIn();
        //     $(".booking-block").hide();
        //     e.preventDefault();
        // }
    }

    function showbillingform() {
        $(this).next().slideDown();
        $(this).remove();
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


    return {
        init: init
    }


})();
