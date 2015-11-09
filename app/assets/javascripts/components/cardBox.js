APP.components.cardBox = (function() {


    function moveActionCard3rd() {
        $(".cardBoxCollection.js-moveActionCard3rd").each(function() {
            var numBoxes = $(this).find(".cardBox").length;
            if (numBoxes > 0) $(this).find(".cardBox:nth-child(3)").after($(".cardbox-wrp"));
        });
    }


    return {
        moveActionCard3rd: moveActionCard3rd
    }

})();


