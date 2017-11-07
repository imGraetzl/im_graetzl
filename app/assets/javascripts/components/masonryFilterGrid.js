APP.components.masonryFilterGrid = (function() {
    var $grid;
    var masonrySetup = false;

    function initGrid() {
      $grid =  $('.masonry-wrapper .cards-container');

      if (masonrySetup) {
        $grid.masonry("destroy");
      }

      $grid.masonry({
        itemSelector: '.cardBox',
        fitWidth : true
      });

      masonrySetup = true;
    }

    function adjustNewCards() {
      $grid.masonry('appended', $(".cardBox").not('[style]'));
    }

    return {
      initGrid: initGrid,
      adjustNewCards: adjustNewCards
    };

})();
