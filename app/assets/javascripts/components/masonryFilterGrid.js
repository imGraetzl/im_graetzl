APP.components.masonryFilterGrid = (function() {

    var $grid;

    function init() {
        $grid =  $('.cards-container');
        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');

        $(window).on("load", function() {
            $grid.masonry();
        });
    }

    function adjustNewCards() {
        $grid.masonry('appended', $(".cardBox").not('[style]'));
    }

    return {
        init: init,
        adjustNewCards: adjustNewCards
    }

})();