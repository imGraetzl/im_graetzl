APP.controllers.groups = (function() {

    function init() {
      if ($(".group-page").exists()) { initGroupPage(); }
    }

    function initGroupPage() {

      APP.components.tabs.initTabs(".tabs-ctrl");

      var target = APP.controllers.application.getUrlVars()["category"];
      if (typeof target !== 'undefined') {
        $('.tabs-ctrl').trigger('show', '#tab-discussions');
      }

      // Load on Pageload if Tab is selected
      if($("#tab-discussions").is(":visible")){
        initDiscussions();
      } else if ($("#tab-meetings").is(":visible")) {
        initMeetings();
      }

      // Load on Tab Change
      $('.tabs-ctrl').on("_after", function() {
          if($("#tab-discussions").is(":visible")){
            initDiscussions();
          } else if ($("#tab-meetings").is(":visible")) {
            initMeetings();
          }
      });

    }


    function selectDiscussion(category) {

      $('input:radio.filter-radio-category').each(function () {
        $(this).prop('checked', false);
      });

      if (typeof category !== "undefined") {
        $('input:radio.filter-radio-category[value='+category+']').prop("checked",true);
      }
      else {
        $('input:radio.filter-radio-category.-all').prop("checked",true);
      }

      APP.components.cardBoxFilter.updateFilterLabels($('#filter-modal-category'));
      APP.components.cardBoxFilter.submitForm();
      APP.components.cardBoxFilter.gtag_tracking($('#filter-modal-category'));

    }


    function initDiscussions() {
      if ($('*[data-behavior="discussions-card-container"]').is(':empty')){
        APP.components.cardBoxFilter.init();
      } else {
        APP.components.cardBoxFilter.submitForm();
      }
    }

    function initMeetings() {
      var $cardCrid = $('*[data-behavior="meetings-card-container"]');
      if ($cardCrid.is(':empty')){
        var $spinner = $('footer .loading-spinner').clone().removeClass('-hidden');
        $cardCrid.append($spinner);
        $('#meeting-submit').submit();
      }
    }

    return {
      init: init,
      selectDiscussion: selectDiscussion
    };


})();
