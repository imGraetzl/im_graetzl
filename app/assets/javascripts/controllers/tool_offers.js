APP.controllers.tool_offers = (function() {

    function init() {
      if ($("section.form-new-toolteiler").exists()) { initToolOfferForm(); }
      if ($("section.toolTeiler-detail").exists()) { initToolOfferDetails(); }
      if ($("section.form-rent-toolteiler").exists()) { initToolteilerRent(); }
    }

    function initToolOfferForm() {
      APP.components.tabs.initTabs(".tabs-ctrl");
      APP.components.addressSearchAutocomplete();

      $(".next-screen").on("click", function() {
        $('.tabs-ctrl').trigger('show', '#' + $(this).data("tab"));
        $('.tabs-ctrl').get(0).scrollIntoView();
      });


      // Prepare SubCategory Dropdown
      var $allSubCategories = [];
      var emptyOption = '<option>auswählen...</option>';
      $(".subcategory-select option").each(function() { $allSubCategories.push($(this)); });
      $(".subcategory-select option").remove();
      $(".subcategory-select").append(emptyOption);

      // Fill SubCategory Dropdown on Change
      $(".category-select").on("change", function() {
        $(".subcategory-select option").remove();
        $(".subcategory-select").append(getOptions($(this).val()));
      }).change();

      // Get SubCategories from selected Parent Category
      function getOptions(parentCategory){
        $filteredSubCategories = [];
        $allSubCategories.forEach(function (item) {
          if (item.data("parent-id") == parentCategory) {
            $filteredSubCategories.push(item);
          }
        });
        if ($filteredSubCategories.length == 0) {
          return emptyOption;
        } else {
          return $filteredSubCategories;
        }
      }

      // Tag Input JS
      $('#custom-keywords').tagsInput({
        'defaultText':'Kurz in Stichworten ..'
      });

    }

    function initToolOfferDetails() {
      $('.request-price-form').find(".date-from, .date-to").pickadate({
        hiddenName: true,
        formatSubmit: 'yyyy-mm-dd',
        format: 'ddd, dd mmm, yyyy',
      }).off('focus').on("change", function() {
        if ($('.request-price-form .date-from').val() && $('.request-price-form .date-to').val()) {
          $('.request-price-form').submit();
        }
      });

      var toolTeilerGallery = new jBox('Image', {
        addClass:'jBoxGallery',
        imageCounter:true,
        preloadFirstImage:true,
        closeOnEsc:true,
        createOnInit:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });

      /*

      Integrate jQuery Mobile and listen to swipe-left / swipe-right.
      Click Control Buttons on Swipe.

      $('.jBoxGallery .jBox-content').on('click', function(){
        $('.jBox-image-pointer-next').click();
      });
      */

    }

    function initToolteilerRent() {
      APP.components.tabs.initTabs(".tabs-ctrl");
      $(".next-screen").on("click", function() {
        $('.tabs-ctrl').trigger('show', '#' + $(this).data("tab"));
        $('.tabs-ctrl').get(0).scrollIntoView();
      });
    }

    return {
      init: init
    };

})();
