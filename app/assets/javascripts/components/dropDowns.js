APP.components.dropDowns = function() {

    $(".dropDownToggle").on("click", function() {
        var $container = $(this).closest("[class*=dropDownMenu]");

        if ($container.hasClass("is-visible")) {
            closeIt();
        } else {
            var id = Math.round(Math.random() * 5000);
            $container.addClass("is-visible");
            $(document.body).on('click.' + id, function(event){
                var $tgt = $(event.target);
                if (!$tgt.closest($container).exists()) {
                    closeIt();
                }
            });
        }

        function closeIt() {
            $container.removeClass("is-visible");
            $(document.body).off('click.' + id);
        }

    });

};