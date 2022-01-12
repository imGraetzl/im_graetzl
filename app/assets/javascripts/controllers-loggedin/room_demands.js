APP.controllers_loggedin.room_demands = (function() {

  function init() {
    if ($("section.room-offer-form").exists()) initRoomForm();
  }

  function initRoomForm() {
    APP.components.graetzlSelectFilter.init($('#area-select'));
    APP.components.search.userAutocomplete();
    $("textarea").autoResize();

    $('#custom-keywords').tagsInput({
      'defaultText':'Kurz in Stichworten ..'
    });

  }

  return {
    init: init
  }


  })();
