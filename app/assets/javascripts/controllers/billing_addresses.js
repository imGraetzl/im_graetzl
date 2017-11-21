APP.controllers.billing_addresses = (function() {
    var $collapsibletrigger;

    function init() {
        $(".initiative-info").children().show();
        $collapsibletrigger = $(".collapsibletrigger");
        bindevents();
    }

    function bindevents() {
        $collapsibletrigger.on("click", showbillingform);
        if (!$collapsibletrigger.data("collapsed")) $collapsibletrigger.trigger("click");
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
