APP.controllers.application = (function() {

    var privateVar = "Sitewide!";

    return {

        init: function() {

            if ($("#error_explanation").exists()) {

                var $markup = ($("#error_explanation").html());
                $("#error_explanation").remove();

                var n = noty({
                    layout: 'center',
                    text: $markup,
                    type: 'error'

                });
            }


        }

    }

})();