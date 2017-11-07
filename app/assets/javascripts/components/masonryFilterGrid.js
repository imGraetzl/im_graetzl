APP.components.masonryFilterGrid = (function() {

    var $grid;

    function init() {
        $grid =  $('.masonry-wrapper .cards-container');

        adjustMasonry();
        $(window).on("load", adjustMasonry);

        createMobileNav();
        $('[data-behavior=createTrigger]').jqDropdown('attach', '[data-behavior=createContainer]');
    }

    function adjustMasonry() {
        $grid.masonry({
            itemSelector: '.cardBox',
            fitWidth : true
        });
    }

    function adjustNewCards() {
      $grid.masonry('appended', $(".cardBox").not('[style]'));
    }

    function createMobileNav() {
        var $dropdown = $(".filter-stream .input-select select");
        $(".filter-stream .iconfilter").not('.createentry, .loginlink').each(function() {
            var $this = $(this),
                link = $this.prop('href'),
                txt = $this.find('.txt').text();

            $dropdown.append(getOption());
            $dropdown.on('change', function() {
                document.location.href = $dropdown.val();
            });

            function getOption() {
                if($this.hasClass('active'))
                    return '<option selected value="'+ link +'">'+ txt +'</option>';
                return '<option value="'+ link +'">'+ txt +'</option>';
            }

        })
    }

    return {
        init: init,
        adjustNewCards: adjustNewCards
    }

})();
