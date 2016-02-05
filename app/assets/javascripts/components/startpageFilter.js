APP.components.startpageFilter = (function() {

    var $createTrigger, $createContainer;

    function init() {


        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');
    }


    return {
        init: init
    }

})();