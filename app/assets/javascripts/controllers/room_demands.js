APP.controllers.room_demands = (function() {

    function init() {
        if ($("section.room-offer-form").exists()) initRoomForm();
    }

    function initRoomForm() {
        APP.components.graetzlSelectFilter.init($('#district-graetzl-select'));

        $('#custom-keywords').tagsInput({
            'defaultText':'Kurz in Stichworten ..'
        });

        $('select#admin-user-select').SumoSelect({
          search: true,
          csvDispCount: 5
        });
    }

    return {
        init: init
    }

})();
