APP.components.stripePayment = (function() {

  function init() {
    const region = $('body').data('region') || 'wien';
    const business_name = region == 'wien' ? 'imGrätzl.at (morgenjungs GmbH)' : 'WeLocally.at (morgenjungs GmbH)'
    const form = $("#payment-form");
    const intent = form.data("intent");
    const clientSecret = form.data("client-secret");
    const redirectUri = form.data("redirect");
    const options = {
      terms: {
        card: 'never',
        sepaDebit: 'never'
      },
      business: {
        name: business_name
      },
      paymentMethodOrder: ['card', 'apple_pay', 'eps', 'sepa_debit', 'google_pay'],
    }
    const appearance = {
      theme: 'flat',
      labels: 'floating',
      variables: {
        colorPrimary: '#69a8a7',
        colorBackground: '#DBEFEC',
        colorText: '#615454',
        colorTextPlaceholder: '#83C7BD',
        colorTextSecondary: '#808080',
        colorDanger: '#ba564d',
        borderRadius: '4px',
        spacingUnit: '3px',
        spacingGridRow: '12px',
        spacingGridColumn: '12px',
        spacingTab: '6px',
      },
      rules: {
        '.Tab': {
          backgroundColor: '#ffffff',
          border: '1px solid #DBEFEC',
          paddingTop: '20px',
          paddingBottom: '20px',
        },
        '.Tab:hover': {
          color: 'var(--colorText)',
          borderColor: '#F8C8C2',
        },
        '.Tab--selected': {
          borderColor: '#69a8a7',
        },
        '.Input': {
          boxShadow: 'inset 1px 1px 1px 0 rgba(0, 0, 0, 0.05)',
        },
        '.Label--resting, .Label--floating': {
          color: '#69a8a7',
        },
      }
    };

    const elements = stripe.elements({ appearance, clientSecret });
    const paymentElement = elements.create("payment", options);
    paymentElement.mount("#payment-element");

    paymentElement.on("ready", function(){
      $('.stripe-spinner').hide();
    });

    form.on("submit", async function(e) {
      e.preventDefault();
      setLoading(form, true);

      let result;
      if (intent == "setup") {
        result = await stripe.confirmSetup({
          elements, confirmParams: { return_url: redirectUri },
        });
      } else if (intent == "payment") {
        result = await stripe.confirmPayment({
          elements, confirmParams: { return_url: redirectUri },
        });
      }

      if (result.error.type === "card_error" || result.error.type === "validation_error") {
        form.find(".error-message").text(result.error.message);
      } else {
        form.find(".error-message").text(result.error.message);
      }

      setLoading(form, false);
    });

    paymentElement.on('change', function(event) {
      form.find(".error-message").text(""); // Clear Error Msg on Change
    });

    // Show Payment Method Infos
    paymentElement.on('change', function(event) {
      $('.payment-method-info').hide();
      if (event.value.type == 'card') {
        $('.payment-method-info.card').show();
      } else if (event.value.type == 'sepa_debit')  {
        $('.payment-method-info.sepa_debit').show();
      } else if (event.value.type == 'sofort')  {
        $('.payment-method-info.sofort').show();
      }
    });

    $(".open-legal").on().on("click", function() {
      $(this).closest('.payment-method-info').find('.legal').slideToggle();
    });

  }

  function setLoading(form, isLoading) {
    var btntext = form.find("#payment-submit").data('btntext') || 'Jetzt unterstützen'
    if (isLoading) {
      // Clear Error Msg / Disable the button and show a spinner
      form.find(".error-message").text("");
      form.find("#payment-submit").attr("disabled", true).text('Autorisierung läuft. Bitte warten ...');

      // If 3d secure Modal is in DOM but doenst open during 10 seconds, show error, reset button & track error
      // [TODO: Remove this in future times]
      setTimeout(() => {        
        let modal3dsecure = document.querySelector('body').firstElementChild;
        let hidden3dsecure = modal3dsecure.querySelector('iframe') && modal3dsecure.style.display == 'none';
        if (hidden3dsecure) {
          setTimeout(() => {  
            // Try again
            if (hidden3dsecure) {
              document.querySelector('html').removeAttribute('tabindex');
              document.querySelector('head').removeAttribute('tabindex');
              document.querySelector('body').removeAttribute('tabindex');
              document.querySelector('body').removeAttribute('style');
              modal3dsecure.remove();
              form.find("#payment-submit").removeAttr("disabled").text(btntext);
              form.find(".error-message").text("Autorisierung nicht möglich, bitte verwende eine andere Zahlungsmethode.");
              gtag('event', `Error :: Autorisierung :: ${form.attr('action')}`);
            }
          }, 4000);
        }
      }, 7000);
      // End of Fix

    } else {
      form.find("#payment-submit").removeAttr("disabled").text(btntext);
    }
  }

  return {
    init: init
  };

})();
