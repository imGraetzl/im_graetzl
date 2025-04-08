APP.controllers_loggedin.room_rentals = (function() {

    function init() {
      if ($(".room-rental-page.date-screen").exists()) {
        initDateScreen();
      } else if ($(".room-rental-page.address-screen").exists()) {
        initAddressScreen();
      } else if ($(".room-rental-page.payment-screen").exists()) {
        initPaymentScreen();
      } else if ($(".room-rental-page.change-payment-screen").exists()) {
        initPaymentChangeScreen();
      } else if ($(".room-rental-page.summary-screen").exists()) {
        initSummaryScreen();
      } else if ($(".room-rental-page.login-screen").exists()) {
        initLoginScreen();
      }
    }

    function initLoginScreen() {
      // Change Wording of Notice Message for RoomRental Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          // Modifiy Message for RoomRental Registrations
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deiner Raumbuchungs-Anfrage.');
        }
      }
    }

    function initDateScreen() {
      APP.components.tabs.setTab('step1');

      var dateInput = $('.rental-date-form');
      var days = dateInput.data("days");
      var disabledDays = [true].concat(days);

      $('.date-screen').on('cocoon:after-insert', function(e, insertedItem) {
        $(insertedItem).find('.datepicker').pickadate({
          hiddenName: true,
          min: true,
          formatSubmit: 'yyyy-mm-dd',
          format: 'ddd, dd mmm, yyyy',
          disable: disabledDays,
          onClose: function() {
            $(document.activeElement).blur();
          },
          // Insert Legend (improve ...)
          onRender: function() {
            $(".rental-date-form .picker__box").append( "<div class='picker__legend'><div class='legend_not_availiable'></div><small class='legend_text'> ... an diesen Tagen nicht verfügbar</small></div>" );
          }
        });
        insertedItem.find('.input-select').addClass('disabled');
      });

      $('.date-screen .datepicker').each(function(i, input) {
        $(input).pickadate({
          hiddenName: true,
          min: true,
          formatSubmit: 'yyyy-mm-dd',
          format: 'ddd, dd mmm, yyyy',
          disable: disabledDays,
          onClose: function() {
            $(document.activeElement).blur();
          },
          // Insert Legend (improve ...)
          onRender: function() {
            $(".rental-date-form .picker__box").append( "<div class='picker__legend'><div class='legend_not_availiable'></div><small class='legend_text'> ... an diesen Tagen nicht verfügbar</small></div>" );
          }
        });
        // pickadate needs help with setting initial value
        $(input).pickadate('picker').set('select', $(input).val(), { format: 'yyyy-mm-dd' });
      });

      $('.date-screen').on('change', '.datepicker', function() {
        const fieldRow = $(this).closest(".date-fields");
        const isActive = !!$(this).val();
      
        fieldRow.find('.hour-input').each(function() {
          $(this).attr("disabled", !isActive);          
          const inputSelect = $(this).closest('.input-select');
          inputSelect.toggleClass('disabled', !isActive);
        });
      });

      $('.date-screen').on('change', '.datepicker, .hour-from', function() {
        var fieldRow = $(this).closest(".date-fields");
        var hoursUrl = fieldRow.data('hours-url');
        var currentDate = fieldRow.find(".datepicker").pickadate('picker').get('select', 'yyyy-mm-dd');
        var hourFrom = fieldRow.find(".hour-input.hour-from").val();
      
        var hourToSelect = fieldRow.find(".hour-input.hour-to");
        var selectedTo = hourToSelect.val(); // Aktueller Wert merken
      
        $.get(hoursUrl, {rent_date: currentDate, hour_from: hourFrom}, function(data) {
          fieldRow.find(".hour-input.hour-from option").not(':empty').each(function(i, o) {
            var hour = +$(o).val();
            $(o).attr("disabled", data.from.indexOf(hour) == -1);
          });
      
          var hasValidTo = false;
          hourToSelect.find("option").not(':empty').each(function(i, o) {
            var hour = +$(o).val();
            var isValid = data.to.indexOf(hour) !== -1;
            $(o).attr("disabled", !isValid);
            if (isValid && +selectedTo === hour) hasValidTo = true;
          });
      
          // Wenn ausgewählte `hour-to` nicht mehr gültig ist → zurücksetzen
          if (selectedTo && !hasValidTo) {
            hourToSelect.val(""); // Reset
          }
        });
      });
      

      $('.date-screen .datepicker').change();

      let hourInputSubmitDelay;

      $('.date-screen').on('change', '.hour-input', function() {
        clearTimeout(hourInputSubmitDelay); // Vorherige geplante Submit abbrechen
        const $form = $(this).closest('form');
        hourInputSubmitDelay = setTimeout(() => {
          $form.submit();
        }, 200);
      });


      $('.date-screen').on('cocoon:after-remove', function() {
        $('.rental-date-form').submit();
      });

      $('.date-screen .next-page').on('click', function() {
        location.href = $(this).attr("href") + "?" + $(".rental-date-form").serialize();
        return false;
      });

      // Change Wording of Notice Message for RoomRental Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Vielen Dank für Deine Registrierung') >= 0){
          // Modifiy Message for RoomRental Registrations
          $("#flash .notice").text('Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet und kannst mit deiner Raumbuchungs-Anfrage fortfahren..');
        }
      }

    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');
    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step3');
      APP.components.stripePayment.init();
    }

    function initPaymentChangeScreen() {
      APP.components.stripePayment.init();
    }

    function initSummaryScreen() {
      APP.components.tabs.setTab('step4');
    }

    return {
      init: init
    };

})();
