APP.components.inputTextareaMovingLabel = function() {

    $(".input-group, .textarea-group").each(function() {

        var $field;
        $(this).hasClass("input-group") ? $field= $(this).find("input") : $field= $(this).find("textarea");

        if($field.val() != "") {
            $(this).addClass("filled");
        }

        $field
            .on("blur", function() {
                if($field.val() != "") {
                    $field.closest("[class*=-group]").addClass("filled");
                } else {
                    $field.closest("[class*=-group]").removeClass("filled");
                }
            }).on("focus", function() {
                $field.closest(".input-group").addClass("filled");
            })
    });

};