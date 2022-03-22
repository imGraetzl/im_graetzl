APP.components.paymentCardSetup = (function() {
  var card, cardReady;
  var form, nameInput, submitButton;

  function init(submitForm) {
    form = submitForm;
    nameInput = submitForm.find('#cardholder-name');
    submitButton = submitForm.find("#card-submit");

    // Create Stripe Card Input and validate it on change
    card = getCardElement();
    cardReady = false;
    card.mount('#card-element');
    card.addEventListener('change', function(event) {
      if (event.error) {
        showFormError(event.error.message);
      } else {
        hideFormError();
      }
      cardReady = event.complete;
      checkCreditCard();
    });

    nameInput.on('input', function() {
      checkCreditCard();
    });

    // On Submit, create payment method and authorize it
    submitButton.on("click", function() {
      submitButton.attr("disabled", true);
      hideFormError();
      stripe.confirmCardSetup(form.data("setup-intent-secret"), {
        payment_method: {
          card: card,
          billing_details: { name: nameInput.val() }
        }
      }).then(function(result) {
        if (result.error) {
          showFormError(result.error.message);
          submitButton.removeAttr("disabled");
        } else {
          form.find("[name=payment_method_id]").val(result.setupIntent.payment_method);
          form.submit();
        }
      });
    });
  }

  function getCardElement() {
    var elements = stripe.elements({
      fonts: [
        { cssSrc: 'https://fonts.googleapis.com/css?family=Lato:400,400i,300' }
      ]
    });

    var style = {
      base: {
        fontFamily: '"Lato", sans-serif',
        fontWeight: 400,
        fontSmoothing: 'antialiased',
        fontSize: '16px',
        color:'#615454',
        '::placeholder': {
          color: '#83C7BD',
          fontStyle:'italic'
        },
        iconColor:'#69a8a7'
      }
    };

    return elements.create('card', {
      style: style, hidePostalCode: true, classes: {base: 'input-plain'}
    });
  }

  function checkCreditCard() {
    if (cardReady && nameInput.val()) {
      submitButton.removeAttr("disabled");
    } else {
      submitButton.attr("disabled", true);
    }
  }

  function showFormError(error) {
    form.find(".error-message").text(error);
  }

  function hideFormError() {
    form.find(".error-message").text("");
  }

  return {
    init: init
  };

})();
