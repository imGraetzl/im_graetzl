APP.controllers_loggedin.crowd_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.amount-screen").exists())  {initAmountScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-pledges-page.detail-screen").exists()) {initDetailScreen();}
      else if ($(".crowd-pledges-page.change-payment-screen").exists()) {initPaymentChangeScreen();}

    }

    function initAmountScreen() {
      APP.components.tabs.setTab('step1');
      initAmount();
      $('.-crowdRewardBox').on("click", function(event) {
        const $rewardBox = $(this);
        const $morelink = $rewardBox.find(".more-link");
        const $rewardDesc = $rewardBox.find(".description");

        if ($(event.target).is("a[target='_blank']")) {
          event.stopPropagation();
          return;
        }

        $rewardBox.toggleClass('-open');
        if ($rewardBox.hasClass("-open")) {
          $morelink.text("Weniger anzeigen");
          // Set Linkify (dont work initial because of css -webkit-line-clamp)
          $rewardDesc.linkify({target: "_blank"});
        } else {
          $morelink.text("Mehr anzeigen");
          // Remove Linkify
          $rewardDesc.find("a").each(function () {
            const text = $(this).text();
            $(this).replaceWith(text);
          });
        }
      });
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');
      initAmount();

      // Change Wording of Notice Message for CrowdPledge Registrations
      if ($("#flash .notice").exists()) {
        var flashText = $("#flash .notice").text();
        if (flashText.indexOf('Vielen Dank für Deine Registrierung') >= 0){
          $("#flash .notice").text('Vielen Dank für Deine Registrierung. Du bist jetzt angemeldet und kannst mit deiner Crowdfunding Unterstützung fortfahren..');
        }
        else if (flashText.indexOf('Super, du bist nun registriert!') >= 0){
          $("#flash .notice").text(flashText + ' Danach gehts weiter mit deiner Crowdfunding Unterstützung.');
        }
      }

      // Slider Input Range
      if ($(".input-range").exists()) {

        const slider = document.getElementById("percentage");
        const listItems = document.querySelectorAll(".range ul.editable li");

        listItems.forEach(li => {
            li.addEventListener("click", function() {
                const value = this.getAttribute("data-value");
                slider.value = value;
                // Slider Event auslösen
                slider.dispatchEvent(new Event("input"));
            });
        });

        const sliderElement = document.querySelector("#percentage");
        const sliderURL = sliderElement.getAttribute('data-url');
        const sliderTotalPrice = sliderElement.getAttribute('data-total-price');
        let sliderColor = "#83C7BD";
        //let sliderColor = "#EC776A";

        sliderElement.addEventListener("input", (event) => {
            const tempSliderValue = event.target.value; 
            const progress = (tempSliderValue / sliderElement.max) * 100;
            sliderElement.style.background = `linear-gradient(to right, ${sliderColor} ${progress}%, #f0f0f0 ${progress}%)`;
            percentageConverter(tempSliderValue);
            savePercentage(tempSliderValue);
        })

        function percentageConverter(value) {
          $("[class^='percent']").removeClass('-show');
          value = parseFloat(value).toFixed(1);
          value = value.toString().replace('.', '_');
          $(".percent-"+value).addClass('-show');
          if (parseFloat(value) === 0) { return };
          $(".percent-info-container .cardBox").removeClass().addClass("percent-" + value + " cardBox -show");
        }

        function calculateBoostChargeForAll(totalPrice) {
          listItems.forEach((listItem) => {
              let boostPercentage = parseFloat(listItem.dataset.value) || 0; // Prozentwert aus data-value holen
              let boostCharge = (totalPrice * (boostPercentage / 100.0)).toFixed(2);
              boostCharge = parseFloat(boostCharge);
              boostCharge = Math.ceil(boostCharge / 0.25) * 0.25;
              listItem.querySelector("small").textContent = `${boostCharge.toFixed(2)} €`; // Mit 2 Nachkommastellen formatieren
          });
        }

        function savePercentage(value) {
          $.ajax({
            url: sliderURL,
            type: "POST",
            data: { crowd_boost_charge_percentage: value }
           });
        }

        function initSlider() {
            const sliderValue = (sliderElement.value / sliderElement.max) * 100;
            sliderElement.style.background = `linear-gradient(to right, ${sliderColor} ${sliderValue}%, #f0f0f0 ${sliderValue}%)`;
            percentageConverter(sliderElement.value);
        }

        $(".percent-info-container .open-more").on('click', function() {
          $('.open-more-content').slideToggle();
        });

        initSlider();

      }



    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step3');
      APP.components.stripePayment.init();
    }

    function initPaymentChangeScreen() {
      APP.components.stripePayment.init();
    }

    function initAmount() {
      // Set Amount on Input
      let timeout = null;
      $(".calculate-price").on("keyup focusout", function() {
        var submit_url = $(this).data('action');
        var amount = $(this).val();
        var dataType = $(this).data("type"); // Data-type auslesen
        var paramName = (dataType === "crowd_boost_charge") ? "crowd_boost_charge_amount" : "donation_amount";

        clearTimeout(timeout);
        timeout = setTimeout(function () {
          $.ajax({
            type: "POST",
            url: submit_url,
            data: paramName + "=" + amount
          });
        }, 750);
      });
      // Limit Max Lenght of Input
      $(".calculate-price").on("input", function() {
        if (this.value.length > this.maxLength) this.value = this.value.slice(0, this.maxLength);
      });

    }

    function initDetailScreen() {
      $('.-pledge-details-toggle').on('click', function() {
        $('.-pledge-details').slideToggle();
      });
    }

    return {
      init: init
    };

})();
