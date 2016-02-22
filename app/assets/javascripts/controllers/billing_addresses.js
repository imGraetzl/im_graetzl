APP.controllers.billing_addresses = (function() {

    function init() {
        $('.zuckerlCollection').masonry({
            percentPosition: true
        });
        $(".initiative-info").children().show();
        bindevents();
    }

    function bindevents() {        
        $(".collapsibletrigger").on("click", showbillingform);
    }

    function showbillingform() {
        $(this).next().slideDown();
        $(this).remove();
    }


// ---------------------------------------------------------------------- Public

    return {
        init: init
    }

})();
