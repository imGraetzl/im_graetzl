APP.components.stripePayment = (function() {

  function init() {
    const form = $("#payment-form");
    const intent = form.data("intent");
    const clientSecret = form.data("client-secret");
    const redirectUri = form.data("redirect");
    const appearance = { theme: 'stripe' };

    const elements = stripe.elements({ appearance, clientSecret });

    const paymentElement = elements.create("payment");
    paymentElement.mount("#payment-element");

    form.on("submit", async function(e) {
      e.preventDefault();
      setLoading(true);

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
        form.find(".error-message").text(error.message);
      } else {
        form.find(".error-message").text("An unexpected error occured.");
      }

      setLoading(false);
    });
  }

  // Show a spinner on payment submission
  function setLoading(isLoading) {
    if (isLoading) {
      // Disable the button and show a spinner
      document.querySelector("#submit").disabled = true;
      document.querySelector("#spinner").classList.remove("hidden");
      document.querySelector("#button-text").classList.add("hidden");
    } else {
      document.querySelector("#submit").disabled = false;
      document.querySelector("#spinner").classList.add("hidden");
      document.querySelector("#button-text").classList.remove("hidden");
    }
  }

  return {
    init: init
  };

})();