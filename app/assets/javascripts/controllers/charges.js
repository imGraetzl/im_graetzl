APP.controllers.charges = (function() {

  function init() {
    initStripe();
  }

  function initStripe() {

    $('.-donate').on('click', function(e) {
      e.preventDefault();

      var amount = $('.amount').val();
      amount = amount.replace(/\$/g, '').replace(/\,/g, '')
      amount = parseFloat(amount);

      if (isNaN(amount)) {
        $('#flash').html('<p>Bitte gib einen gültigen Betrag (€) ein.</p>').show();
      }
      else if (amount < 3.00) {
        $('#flash').html('<p>Der Betrag muss mindestens 3 € betragen.</p>').show();
      }
      else {
        $('#flash').hide();
        amount = amount * 100; // Needs to be an integer!
        handler.open({
          amount: Math.round(amount)
        })
      }
    });

    // Close Checkout on page navigation
    $(window).on('popstate', function() {
      handler.close();
    });

  }

  return {
    init: init
  };

})();
