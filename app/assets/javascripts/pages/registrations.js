APP.pages.registrations = (function() {

    var steps = {};
    var wizard;


    steps.searchGraetzl = (function() {

        var $container;

        function events() {
            $container.on("click", ".btn", function() {
                if(!$container.find(".manual").is(":visible")) {
                    $container.find(".manual").fadeIn();
                    $container.find(".assisted").hide();
                    $(this).text("Adresssuche verwenden");
                    wizard.slider.trigger("updateSizes");
                } else {
                    $container.find(".assisted").fadeIn();
                    $container.find(".manual").hide();
                    $(this).text("Manuell w�hlen");
                }
            });
        }

        return {
            init: function() {
                $container = $(".step-search");
                events();
            },

            onEnter: function() {
                console.log("enter gr�tzl search");
            },

            onExit: function() {
                console.log("exit gratzl search");
            }
        }

    })();


    steps.personalData = (function() {

        return {
            init: function() {
                console.log("init personalData");
            },

            onEnter: function() {
                console.log("enter personalData");
            },

            onExit: function() {
                console.log("exit personalData");
            },

            validate: function() {
                console.log("validate personalData");
                return true;
            }
        };

    })();


    return {

        init: function() {

            $('#user_birthday').mask('00/00/0000');

        }
    }

})();