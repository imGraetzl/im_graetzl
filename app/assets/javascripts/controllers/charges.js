APP.controllers.charges = (function() {

  function init() {
    if($('#stripeForm').exists()) initStripe();
  }

  function initStripe() {

    var handler = StripeCheckout.configure({
      key: $('#stripeForm #publishable_key').val(),
      locale: 'de',
      currency: 'eur',
      allowRememberMe: false,
      name: 'imGrätzl.at',
      description: $('#stripeForm #stripeDescription').val(),
      email: $('#stripeForm #currentUserEmail').val(),
      token: function(response) {
        // Get Stripe response infos and pass to hidden form fields
        $('#stripeForm #stripeToken').val(response.id);
        $('#stripeForm #stripeEmail').val(response.email);
        $('#stripeForm').submit();
      }
    });

    // Submit Stripe Form
    $('.stripe-submit').on('click', function(e) {
      e.preventDefault();

      var amount = $('#stripeForm .amount').val();
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
