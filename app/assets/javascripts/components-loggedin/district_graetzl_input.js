APP.components.districtGraetzlInput = function() {

  var districtInput = $(".district-input");
  if (districtInput.length == 0) return;

  var graetzlInput = $(".graetzl-input");
  var graetzlInputSource = graetzlInput.clone();

  districtInput.on('change', function() {
    var districtId = $(this).val();
    if (!districtId) return;

    graetzlInput.find("option").remove();
    graetzlInput.append(graetzlInputSource.find("[data-district-id='" + districtId + "']").clone());

  }).trigger("change");

};
