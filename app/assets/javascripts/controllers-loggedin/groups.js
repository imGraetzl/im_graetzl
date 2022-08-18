APP.controllers_loggedin.groups = (function() {

    function init() {
      if ($(".group-page").exists()) { initGroupPage(); }
      if ($(".group-form-page").exists()) { initGroupForm(); }
    }

    function initGroupPage() {

      var mobCreate = new jBox('Modal', {
        addClass:'jBox',
        attach: '.mob #createTopic',
        content: $('#jBoxCreateTopic'),
        trigger: 'click',
        closeOnClick:true,
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
      });

      var deskCreate = new jBox('Tooltip', {
        addClass:'jBox',
        attach: '.desk #createTopic',
        content: $('#jBoxCreateTopic'),
        trigger: 'click',
        closeOnClick:true,
        pointer:'right',
        adjustTracker:true,
        isolateScroll:true,
        adjustDistance: {top: 25, right: 25, bottom: 25, left: 25},
        animation:{open: 'zoomIn', close: 'zoomOut'},
        maxHeight:500,
      });

      var joinRequest = new jBox('Modal', {
        addClass:'jBox',
        attach: '#joinRequest',
        content: $('#jBoxRoinRequest'),
        trigger: 'click',
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        width:750
      });

      var joinRequestMessage = new jBox('Modal', {
        addClass:'jBox',
        attach: '.request-message-opener',
        trigger: 'click',
        blockScroll:true,
        animation:{open: 'zoomIn', close: 'zoomOut'},
        onOpen: function() {
          var id = this.source.attr('data-content-id');
          this.setContent($('#' + id).clone());
        },
        width:750
      });

      $('select#mail-user-select').SumoSelect({
        search: true,
        searchText: 'Suche nach User.',
        placeholder: 'User auswählen',
        csvDispCount: 2,
        captionFormat: '{0} Gruppenmitglieder',
        captionFormatAllSelected: 'Alle Gruppenmitglieder',
        okCancelInMulti: true,
        selectAll: true,
        locale: ['Auswählen', 'Abbrechen', 'Alle auswählen']
      });

    }

    function initGroupForm() {
      $(".group-categories input").on("change", function() {
        if ($(".group-categories input:checked").length >= 3) {
          $(".group-categories input:not(:checked)").each(function() {
            $(this).prop("disabled", true);
            $(this).parents(".input-checkbox").addClass("disabled");
          });
        } else {
          $(".group-categories input").prop("disabled", false);
          $(".group-categories .input-checkbox").removeClass("disabled");
        }
      });
      APP.components.graetzlSelectFilter.init($('#area-select'));
    }


    return {
      init: init
    };


})();
