APP.controllers.application = (function() {

    var privateVar = "Sitewide!";



    return {

        init: function() {


            //input fields label effect TODO: place code in module
            $(".input-group").each(function() {
                var $input= $(this).find("input");

                if($input.val() != "") {
                    $(this).addClass("filled");
                }

                $input
                    .on("blur", function() {
                        if($input.val() != "") {
                            $input.closest(".input-group").addClass("filled");
                        } else {
                            $input.closest(".input-group").removeClass("filled");
                        }
                    }).on("focus", function() {
                        $input.closest(".input-group").addClass("filled");
                    })
            })

        }

    }

})();