APP.controllers.room_offers = (function() {

    function init() {
        if ($("section.room-offer-form").exists()) initRoomForm();
    }

    function initRoomForm() {
        APP.components.addressSearchAutocomplete();
    }

    return {
        init: init
    }

})();
