APP.components.startpageFilter = (function() {

    function init() {
        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');

        $(window).on("load", function() {
            $('.cards-container').masonry();
        })
    }

    return {
        init: init
    }

})();