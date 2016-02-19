APP.components.startpageFilter = (function() {

    function init() {


        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');


        var $grid = $('.cards-container').masonry({
            percentPosition: true
        });

        setInterval(function() {
            $grid.masonry('layout');
        }, 1000);



    }


    return {
        init: init
    }

})();