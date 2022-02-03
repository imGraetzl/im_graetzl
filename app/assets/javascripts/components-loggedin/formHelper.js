APP.components.formHelper = (function() {

  function maxCategories(container, max) {
    if (container.find("input:checked").length >= max) {
      container.find("input:not(:checked)").each(function() {
        $(this).prop("disabled", true);
        $(this).parents(".input-checkbox").addClass("disabled");
      });
    } else {
      container.find("input").prop("disabled", false);
      container.find(".input-checkbox").removeClass("disabled");
    }
  }

  return {
    maxCategories: maxCategories
  };

})();
