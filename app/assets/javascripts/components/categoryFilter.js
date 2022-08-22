APP.components.categoryFilter = (function() {

  function init(element) {
    var item_desk = 5;
    var item_tab = 3;
    var item_mob = 2;

    var filterForm = $(".cards-filter");
    var filterLine = $(".filter-line");
    var categorylink = filterForm.find('.category-slider-label');

    var slider = element.lightSlider({
      item: item_desk,
      slideMove: item_desk, // slidemove will be 1 if loop is true
      auto: false,
      pause: 15000,
      controls: true,
      pager: false,
      currentPagerPosition: 'middle',
      pauseOnHover: true,
      addClass: '-desktop',
      responsive : [
        {
          breakpoint:850,
          settings: {
            item: item_tab,
            slideMove: item_tab,
            addClass: '-tablet'
          }
        },
        {
          breakpoint:415,
          settings: {
            item: item_mob,
            slideMove: item_mob,
            controls: false,
            pager: true,
            addClass: '-mobile'
          }
        }
      ],
      onSliderLoad: function(el) {
        sliderLoaded(el)
      }
    });

    // Hover Slide
    element.find('.-category').hover(
     function(){ $(this).addClass('hover') },
     function(){ $(this).removeClass('hover')}
   );

   function sliderLoaded(el) {
     $(el).removeClass('cS-hidden');
     $(el).closest(".category-slider-container").removeClass('loading');
     initSelectedCategory();
   }

   // Click Slide
   element.find('.-category').on('click', function(event){
     event.preventDefault();

     if ($(this).hasClass("activated")) {

         $(this).removeClass('activated');
         filterForm.find("[name=category_id]").val("");
         filterForm.find("[name=special_category_id]").val("");
         updateFilterLabels($(this));
         APP.components.cardBoxFilter.submitForm();
         history && history.replaceState({}, '', location.pathname.split('/category/')[0]);

     } else {

         if ($(this).hasClass("-href")) {
           window.location.href = $(this).attr("data-href");
           return;
         } else if ($(this).hasClass("-special-category")) {
             // Special Filter Selected
             filterForm.find("[name=category_id]").val("");
             filterForm.find("[name=special_category_id]").val($(this).attr("data-id"));
             history && history.replaceState({}, '', location.pathname.split('/category/')[0] + "/category/" + $(this).attr("data-slug"));
         } else {
             // Normal Filter Selected
             filterForm.find("[name=special_category_id]").val("");
             filterForm.find("[name=category_id]").val($(this).attr("data-id"));
             if ($(this).attr("data-slug")) {
               history && history.replaceState({}, '', location.pathname.split('/category/')[0] + "/category/" + $(this).attr("data-slug"));
             }
         }

         var src = element.find(".activated .catimg").data("src");
         element.find(".activated .catimg").attr("src",src);
         element.find('.-category').removeClass('activated');
         $(this).addClass('activated');
         updateFilterLabels($(this));
         APP.components.cardBoxFilter.submitForm();
         categoryClickTracking($(this))

     }
   });


   // Analytics Tracking
   function categoryClickTracking(category) {
     if (category.hasClass("activated")) {
       var label_item = category.attr("data-label");
       var label_type = $('#category-slider').attr("data-label");
       gtag(
         'event', label_type + ' :: Category Slider', {
         'event_category': 'Filter',
         'event_label': label_item
       });
     }
   }

   // Update Text Label if exists on Page
   function updateFilterLabels(category) {
     if (typeof categorylink !== "undefined") {
        var src = category.find(".catimg").data("src");
        var srcactive = category.find(".catimg").data("srcactive");

         if (category.hasClass("activated")) {
           var label = category.attr("data-label");
           categorylink.text(label);
           category.find(".catimg").attr("src",srcactive);
         } else {
           categorylink.text(categorylink.data("no-filter-label"));
           category.find(".catimg").attr("src",src);
         }
     }
   }


   // Init selected Category if Param present on Load
   function initSelectedCategory() {

     var selected_category = filterForm.find("[name=category_id]").val();
     var selected_special_category = filterForm.find("[name=special_category_id]").val();
     element.find('.-category[data-id="' + selected_category + '"]').addClass('activated');
     element.find('.-category[data-id="' + selected_special_category + '"]').addClass('activated');

     updateFilterLabels(element.find('.activated'));

   }

  }

  return {
    init: init
  };

})();
