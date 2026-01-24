APP.controllers_loggedin.crowd_pledges = (function() {

    function init() {
      if      ($(".crowd-pledges-page.amount-screen").exists())  {initAmountScreen();}
      else if ($(".crowd-pledges-page.address-screen").exists()) {initAddressScreen();}
      else if ($(".crowd-pledges-page.payment-screen").exists()) {initPaymentScreen();}
      else if ($(".crowd-pledges-page.processing-screen").exists()) {initProcessingScreen();}
      else if ($(".crowd-pledges-page.crowd-boost-charge-screen").exists()) {initBoostChargeScreen();}
      else if ($(".crowd-pledges-page.detail-screen").exists()) {initDetailScreen();}
      else if ($(".crowd-pledges-page.change-payment-screen").exists()) {initPaymentChangeScreen();}
    }

    function initAmountScreen() {
      APP.components.tabs.setTab('step1');
      initAmount();
      initRewardImageModal();
      $('.-crowdRewardBox').on("click", function(event) {
        const $rewardBox = $(this);
        const $morelink = $rewardBox.find(".more-link");
        const $rewardDesc = $rewardBox.find(".description");

        if ($(event.target).closest(".js-reward-image").length) {
          return;
        }

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

    function initRewardImageModal() {
      if (!$(".js-reward-image[data-full-src]").exists()) return;

      new jBox('Image', {
        attach: '.js-reward-image[data-full-src]',
        src: 'data-full-src',
        gallery: 'data-reward-gallery',
        closeOnClick: true
      });
    }

    function initAddressScreen() {
      APP.components.tabs.setTab('step2');

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
    }

    function initBoostChargeScreen() {

      const calculateURL = document.querySelector("#charge-amount-radios").dataset.url;
      const systemRadios = document.querySelectorAll('.system-radios input[name="crowd_pledge[crowd_boost_charge_amount]"]');
      const customWrapper = document.querySelector(".custom-amount-option");
      const customInput = document.getElementById('custom_crowd_boost_charge_amount');
      const customRadio = document.getElementById('crowd_pledge_amount_custom');

      let saveTimeout = null;

      function handleDelayedSave(inputValue) {
        clearTimeout(saveTimeout);
        saveTimeout = setTimeout(function () {
          saveBoostAmount(inputValue);
        }, 750);
      }

      function handleInput(event) {
        
        let value = event.target.value;

        // Punkt in Komma umwandeln (z. B. 12.3 → 12,3)
        value = value.replace(/\./g, ',');

        // Alle Zeichen außer Ziffern und Komma entfernen
        value = value.replace(/[^0-9,]/g, '');

        // Split bei Komma (max. 1 erlaubt)
        const parts = value.split(',');

        const beforeComma = parts[0].slice(0, 4); // Max. 4 Stellen vor dem Komma
        const afterComma = parts[1] ? parts[1].slice(0, 2) : ''; // Max. 2 Stellen nach dem Komma (optional)

        const newValue = parts.length > 1 ? `${beforeComma},${afterComma}` : beforeComma;

        event.target.value = newValue;
        customRadio.value = newValue;

        handleDelayedSave(newValue);
      }

      function handleFocusIn() {
        customRadio.checked = true;
        customInput.value = '';
        customRadio.value = '';
        saveBoostAmount(0);
      }

      function handleFocusOut() {
        let value = customInput.value;
      
        if (!value) return;
      
        // Punkt durch Komma ersetzen (für Sicherheit)
        value = value.replace(/\./g, ',');
      
        // Nur Ziffern und max. 1 Komma
        value = value.replace(/[^0-9,]/g, '');
        const parts = value.split(',');
      
        let beforeComma = parts[0].slice(0, 4); // Max 4 Ziffern
        if (!beforeComma) beforeComma = '0';

        // Führende Nullen entfernen (z. B. 0001 → 1)
        beforeComma = beforeComma.replace(/^0+/, '') || '0';
            
        customInput.value = `${beforeComma},00`;
      }

      customInput.addEventListener("input", handleInput);
      customInput.addEventListener("focusin", handleFocusIn);
      customInput.addEventListener("focusout", handleFocusOut);

      customInput.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
          event.preventDefault();
          customInput.blur();
        }
      });

      customWrapper.addEventListener("click", function () {
        customInput.focus();
      });

      systemRadios.forEach((radio) => {
        radio.addEventListener("change", () => {
          if (radio !== customRadio) {
            customInput.value = '';
          }
          saveBoostAmount(radio.value);
        });
      });

      const initiallyChecked = document.querySelector('input[name="crowd_pledge[crowd_boost_charge_amount]"]:checked');
      if (initiallyChecked) {
        saveBoostAmount(initiallyChecked.value);
      }

      function saveBoostAmount(value) {
        const amount = value && value.trim() !== '' ? value : '0';
        $.ajax({
          url: calculateURL,
          type: "POST",
          data: { crowd_boost_charge_amount: amount }
         });
      }

      // Charge Screen Tracking
      const el = document.querySelector("#crowd-pledge-charge");
      if (!el) return;

      const pledgeId = el.dataset.pledgeId;
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      let seenTracked = false;
      let seenTimeout = null;

      // 1. Sofort beim Laden: charge_returned
      fetch(`/crowd_pledges/${pledgeId}/charge_returned`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Content-Type": "application/json"
        },
        credentials: "same-origin"
      });

      // 2. Sichtbarkeit prüfen und verzögert ausführen
      function markAsSeen() {
        if (!seenTracked && document.visibilityState === "visible") {
          // Startet den Timer nur einmal
          seenTimeout = setTimeout(() => {
            if (document.visibilityState === "visible") {
              seenTracked = true;

              fetch(`/crowd_pledges/${pledgeId}/charge_seen`, {
                method: "POST",
                headers: {
                  "X-CSRF-Token": csrfToken,
                  "Content-Type": "application/json"
                },
                credentials: "same-origin"
              });
            }
          }, 1500); // Warte 1 Sekunde sichtbar
        }
      }

      // 3. Wenn Sichtbarkeit sich ändert
      document.addEventListener("visibilitychange", markAsSeen);

      // 4. Falls Seite direkt sichtbar geladen wurde
      if (document.visibilityState === "visible") {
        markAsSeen();
      }

      // 5. Fallback für iOS/Safari: Timeout beim Laden (wenn sichtbar)
      document.addEventListener("DOMContentLoaded", () => {
        if (document.visibilityState === "visible") {
          markAsSeen();
        }
      });

    }

    function initPaymentScreen() {
      APP.components.tabs.setTab('step3');
      APP.components.stripePayment.init();
    }

    function initProcessingScreen() {
      const container = document.querySelector(".crowd-pledges-page.processing-screen");
      if (!container) return;

      const pollUrl = container.dataset.pollUrl;
      const initialDelay = parseInt(container.dataset.initialDelayMs || "1500", 10);
      const intervalMs = parseInt(container.dataset.intervalMs || "3000", 10);
      const timeoutMs = parseInt(container.dataset.timeoutMs || "9000", 10);
      const fallbackUrl = container.dataset.fallbackUrl;
      const statusEl = container.querySelector("[data-processing-status]");

      let elapsed = 0;
      let pollTimer = null;
      let polling = false;
      
      function stopPolling() {
        if (pollTimer) clearInterval(pollTimer);
        pollTimer = null;
      }

      function updateStatus(text) {
        if (statusEl) statusEl.textContent = text;
      }

      function handleFailure(message, redirectUrl) {
        stopPolling();
        updateStatus(message || "Die Autorisierung konnte nicht abgeschlossen werden.");
        if (redirectUrl) {
          const url = new URL(redirectUrl, window.location.origin);
          url.searchParams.set("fallback_reason", "processing_failed");
          setTimeout(function() { window.location = url.toString(); }, 1500);
        } else if (fallbackUrl) {
          const url = new URL(fallbackUrl, window.location.origin);
          url.searchParams.set("fallback_reason", "processing_failed");
          setTimeout(function() { window.location = url.toString(); }, 1500);
        }
      }

      function pollStatus() {
        if (polling || !pollUrl) return;
        polling = true;

        fetch(pollUrl, {
          headers: { "Accept": "application/json" },
          credentials: "same-origin"
        })
        .then(function(response) {
          if (!response.ok) {
            throw new Error("Polling failed");
          }
          return response.json();
        })
        .then(function(payload) {
          if (payload.status === "succeeded" && payload.redirect_url) {
            stopPolling();
            updateStatus("Erfolgreich bestätigt. Weiterleitung…");
            window.location = payload.redirect_url;
          } else if (payload.status === "failed") {
            handleFailure(payload.message, payload.redirect_url || fallbackUrl);
          } else if (payload.status === "invalid") {
            handleFailure("Der Autorisierungsstatus konnte nicht mehr geprüft werden.", fallbackUrl);
          } else {
            updateStatus("Status: " + payload.status.replace(/_/g, ' '));
          }
        })
        .catch(function() {
          updateStatus("Status: Verbindung unterbrochen – versuche erneut …");
          handleFailure("Die Verbindung wurde unterbrochen.", null);
        })
        .finally(function() {
          polling = false;
        });
      }

      setTimeout(function() {
        pollStatus();
        pollTimer = setInterval(function() {
          elapsed += intervalMs;
          if (elapsed >= timeoutMs) {
            handleFailure(null, fallbackUrl);
            return;
          }
          pollStatus();
        }, intervalMs);
      }, initialDelay);

      // Optional: Bei Bedarf hier weitere UI-Effekte ergänzen.
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
