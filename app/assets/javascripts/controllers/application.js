APP.controllers.application = (function() {

    var privateVar = "Sitewide!";

    function navigation() {

        enquire.register("screen and (min-width: 650px)", {

            deferSetup : true,
            setup : function() {
                console.log("init 650");
            },
            match : function() {
                console.log("jo now 650");
            },
            unmatch : function() {
                console.log("650 nomore");
            }

        });

        enquire.register("screen and (min-width: 1015px)", {

            deferSetup : true,
            setup : function() {
                console.log("init 1015");
            },
            match : function() {
                console.log("jo now 1015");
            },
            unmatch : function() {
                console.log("1015 nomore");
            }

        });


    }


    return {

        init: function() {

            navigation();

            /*
            if ($("#error_explanation").exists()) {

                var $markup = ($("#error_explanation").html());
                $("#error_explanation").remove();

                var n = noty({
                    layout: 'center',
                    text: $markup,
                    type: 'error'

                });
            }
            */


        }

    }

})();