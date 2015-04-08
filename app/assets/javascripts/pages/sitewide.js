APP.pages.sitewide = (function() {

    var privateVar = "Sitewide!";



    return {

        init: function() {

            $(".input-group").each(function() {
                var $input= $(this).find("input");
                $input.on("blur", function() {
                    if($input.val() != "") {
                        $input.closest(".input-group").addClass("filled");
                    } else {
                        $input.closest(".input-group").removeClass("filled");
                    }
                })
            })

        }

    }

})();