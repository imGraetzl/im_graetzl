APP.utils = (function() {

    // ---------------------------------------------------------------------- Custom Functions

    function getMq(def) {
        var mq;
        if (def == ">=medium") {
            mq = "(min-width: "+ APP.config.majorBreakpoints.medium + "px)";
        } else if (def == ">=large") {
            mq = "(min-width: "+ APP.config.majorBreakpoints.large + "px)";
        } else if (def == "<medium") {
            mq = "(max-width: "+ (APP.config.majorBreakpoints.medium-1) + "px)";
        } else if (def == "<large") {
            mq = "(max-width: "+ (APP.config.majorBreakpoints.large-1) + "px)";
        }
        return mq;
    }

    // ---------------------------------------------------------------------- Returns

    return {
        getMq: getMq
    }

})();


//micro jQuery plugin to check if a given element exists
jQuery.fn.exists = function(){
    return this.length;
};
