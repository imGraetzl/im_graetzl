APP.utils = (function() {



})();


//micro jQuery plugin to check if a given element exists
$.fn.exists = function(){
    return this.length;
};


$.fn.showMoreOnTyping = function( options ) {

    var settings = $.extend({
        charCount: 5,
        elementsToShow: function() {}
    }, options );

    return this.each(function() {

        var $this = $(this);
        var $elementsToShow = settings.elementsToShow.call(this);

        if($this.val().length > settings.charCount) {
            $elementsToShow.show();
        }

        $this.on("keyup", function () {

            if ($this.val().length > settings.charCount) {
                $elementsToShow.fadeIn();
            } else {
                $elementsToShow.hide();
            }
        });

    });

};
