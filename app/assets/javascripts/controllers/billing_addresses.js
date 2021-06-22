APP.controllers.billing_addresses = (function() {
    var $collapsibletrigger;

    function init() {
        $collapsibletrigger = $(".collapsibletrigger");
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
