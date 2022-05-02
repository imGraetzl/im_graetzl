APP.components.stripePayment = (function() {

  function init() {
    const form = $("#payment-form");
    const intent = form.data("intent");
    const clientSecret = form.data("client-secret");
    const redirectUri = form.data("redirect");
    const options = {
      terms: {
        card: 'never',
        //sepaDebit: 'never'
        //sofort: 'never'
      },
      business: {
        name: 'imGrätzl.at (morgenjungs GmbH)'
      },
      fields: {
        //billingDetails: 'never'
      },
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
        form.find(".error-message").text("An unexpected error occured.");
      }

      setLoading(form, false);
    });
  }

  function setLoading(form, isLoading) {
    if (isLoading) {
      // Disable the button and show a spinner
      form.find("#payment-submit").attr("disabled", true);
    } else {
      form.find("#payment-submit").removeAttr("disabled");
    }
  }

  return {
    init: init
  };

})();
