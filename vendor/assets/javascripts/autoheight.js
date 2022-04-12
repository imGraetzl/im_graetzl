//
// Copyright Kamil Pękala http://github.com/kamilkp
// autoheight v0.0.1
//
;(function(window, document, $){
	/* jshint eqnull:true */
	/* jshint -W041 */

	if($ == null) throw new Error('jQuery is not defined!');

	var msie = +((/msie (\d+)/.exec(navigator.userAgent.toLowerCase()) || [])[1]);
	if (isNaN(msie))
		msie = +((/trident\/.*; rv:(\d+)/.exec(navigator.userAgent.toLowerCase()) || [])[1]);

	$.fn.autoheight = function(){
		this.each(function(index, element){
			var $element = $(element);
	        // listeners not attached yet
	        if($element.attr('autoheight') == null){
				$element.attr('autoheight', '');
				// user input, copy, paste, cut occurrences
				$(element).on('input change', adjust.bind(null, element));
	        }

			// initial adjust
	        adjust(element);
		});

		return this;

        function adjust(node){
            var lineHeight = getLineHeight(node);
            if(!(node.offsetHeight || node.offsetWidth)) return;
            if(node.scrollHeight <= node.clientHeight)
                node.style.height = '0px';
            var h = node.scrollHeight + // actual height defined by content
                    node.offsetHeight - // border size compensation
                    node.clientHeight; //       -- || --
            node.style.height = Math.max(h, lineHeight) +
                                (msie && lineHeight ? lineHeight : 0) + // ie extra row
                                'px';
        }
	};

    function getLineHeight(node){
        var computedStyle = window.getComputedStyle(node);
        var lineHeightStyle = computedStyle.lineHeight;
        if(lineHeightStyle === 'normal') return +computedStyle.fontSize.slice(0, -2);
        else return +lineHeightStyle.slice(0, -2);
    }

	//$(document.head).append(
	//	'<style>[autoheight]{overflow: hidden; resize: none; box-sizing: border-box;}</style>'
	//);

})(window, document, window.jQuery);
