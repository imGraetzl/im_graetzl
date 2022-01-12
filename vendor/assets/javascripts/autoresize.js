/*!
 * jQuery textarea autoResize plugin v0.0.2 - 2016-08-31
 * http://github.com/kipruss/jquery-autoresize
 * Author: Konstantin Baev for Magic Web Solutions ( http://magicwebsolutions.co.uk/ )
 * Licensed under the MIT license
 */

;(function() {
    'use strict';

    var $ = this.$,

        defaults = {
            resize: $.noop,
            'minRows': 1,
            'maxRows': 0
        };

    $.fn.autoResize = function(options) {
        var settings = $.extend({}, defaults, options);

        this.filter('textarea').each(function() {

            var $textarea = $(this).css({
                    'overflow-y': 'hidden',
                    'height': 'auto',
                    'resize': 'none'
                });

            var textarea = $textarea.get(0);

            var setBaseScrollHeight = function () {
                var savedValue = textarea.value;
                var savedRows = textarea.rows;
                textarea.value = '';
                textarea.rows = 1;
                textarea.baseScrollHeight = textarea.scrollHeight;
                textarea.value = savedValue;
                textarea.rows = savedRows;
            };

            var init = function () {
                if (!textarea.scrollHeight) return false;
                if (textarea.baseScrollHeight) return true;
                setBaseScrollHeight();
                return true;
            };

            var setRows = function () {
                if (!init()) return false;
                var lineHeight = parseInt($textarea.css('line-height'));
                textarea.rows = settings.minRows;
                var rows = Math.ceil((textarea.scrollHeight - textarea.baseScrollHeight) / lineHeight) + 1;
                if (settings.maxRows > settings.minRows && rows > settings.maxRows) {
                    textarea.rows = settings.maxRows;
                    $textarea.css({ 'overflow-y': 'auto' });
                } else {
                    textarea.rows = Math.max(rows, settings.minRows);
                    $textarea.css({ 'overflow-y': 'hidden' });
                }
            };

            if (!textarea.rows || textarea.rows < settings.minRows) {
                textarea.rows = settings.minRows;
            }
            $textarea.off('.resize');

            if (supportsInputEvent()) {
                $textarea.on('input.resize', setRows);
            } else if (supportsPropertyChangeEvent()) {
                $textarea.on('propertychange.resize', setRows);
            } else {
                $textarea.on('keypress.resize', setRows);
            }
            $textarea.one('focus', setRows);
            setRows();
        });

        return this;
    };

    function supportsInputEvent() {
        if ('oninput' in document.body) {
            return true;
        }

        document.body.setAttribute('oninput', 'return');

        var supports = typeof document.body.oninput === 'function';
        delete document.body.oninput;
        return supports;
    }

    function supportsPropertyChangeEvent() {
        return 'onpropertychange' in document.body;
    }

}).call(this);
