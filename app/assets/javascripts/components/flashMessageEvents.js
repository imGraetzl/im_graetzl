APP.components.flashMsgEvents = (function() {

  function flashMsg(message) {
    var notice = document.querySelector("#flash .notice");
    return notice && notice.textContent.includes(message);
  }

  function init() {
    // Registration SignUp
    if (flashMsg('Super, du bist nun registriert!')) {
      console.log('signup');
      gtag('event', 'sign_up');
    }
    // Purchase
    else if (flashMsg('Deine Zahlung wurde erfolgreich autorisiert.')) {
      var summaryScreen = document.querySelector(".summary-screen[data-transaction-id]");
      if (summaryScreen) {
        gtag("event", "purchase", {
          transaction_id: summaryScreen.dataset.transactionId,
          value: summaryScreen.dataset.value,
          currency: "EUR"
        });
      }
    }
  }

  return { init };

})();
