// Initialisiert EIN Autocomplete-Input robust (nur 1x pro Element)
function initAdminAutocompleteInput(input) {
  if (input._autocompleteInitialized) return; // Schon initialisiert? Dann überspringen.
  input._autocompleteInitialized = true;

  const url = input.dataset.autocompleteUrl;
  const targetName = input.dataset.targetInput;

  // Results-Box anlegen
  const resultsBox = document.createElement('ul');
  resultsBox.classList.add('admin-autocomplete-results');
  input.parentNode.appendChild(resultsBox);
  input.parentNode.classList.add('admin-autocomplete-container');

  // Hidden-Input für Filter-Formulare sicherstellen
  const ensureHiddenInput = () => {
    if (!targetName) return null;
    let hidden = input.form.querySelector(`input[name="${targetName}"]`);
    if (!hidden) {
      hidden = document.createElement('input');
      hidden.type = 'hidden';
      hidden.name = targetName;
      input.form.appendChild(hidden);
    }
    return hidden;
  };

  // Autocomplete-Listener
  input.addEventListener('input', () => {
    resetHiddenIfEmpty(input);

    const q = input.value.trim();
    if (q.length < 4) {
      resultsBox.innerHTML = '';
      resultsBox.style.display = 'none';
      return;
    }

    const scope = input.dataset.scope;
    const resource = input.dataset.resource || 'users';
    const includeGuests = input.dataset.includeGuests === 'true' || input.dataset.includeGuests === '1';
    const joiner = url.includes('?') ? '&' : '?';
    const finalUrl = `${url}${joiner}q=${encodeURIComponent(q)}&resource=${resource}${scope ? `&scope=${encodeURIComponent(scope)}` : ''}${includeGuests ? '&include_guests=1' : ''}`;

    fetch(finalUrl)
      .then(res => res.json())
      .then(data => {
        resultsBox.innerHTML = '';
        
        const renderItem = (item) => {
          if (resource === 'users') {
            const name = item.full_name || item.email || '';
            const suffix = item.guest ? 'Guest' : item.username;
            return `
              <div class="eac-item">
                <div class="item User">
                  <img src="${item.image_url}">
                  <div class="txt">
                    <span>${item.region}</span><br>
                    <strong>${name}</strong>${suffix ? ` (${suffix})` : ''}<br>
                    <span>${item.email}</span>
                  </div>
                </div>
              </div>
            `;
          }
          if (resource === 'locations') {
            return `
              <div class="eac-item">
                <div class="item Location">
                  <img src="${item.image_url}">
                  <div class="txt">
                    <span>${item.region || ''}</span><br>
                    <strong>${item.name}</strong><br>
                    <span>${item.autocomplete_display_name || ''}</span>
                  </div>
                </div>
              </div>
            `;
          }
        };

        const handleClick = (item) => {
          if (resource === 'users') {
            const autocompleteId = input.dataset.userAutocompleteId;
            if (autocompleteId) {
              const hiddenInput = input.form.querySelector(`.admin-autocomplete-id-target[data-user-autocomplete-id="${autocompleteId}"]`);
              if (hiddenInput) hiddenInput.value = item.id;
            }
            input.value = item.autocomplete_display_name || `${item.full_name} (${item.username})`;
          }

          if (resource === 'locations') {
            const autocompleteId = input.dataset.locationAutocompleteId;
            if (autocompleteId) {
              const hiddenInput = input.form.querySelector(`.admin-autocomplete-id-target[data-location-autocomplete-id="${autocompleteId}"]`);
              if (hiddenInput) hiddenInput.value = item.id;
            }
            input.value = item.name;
          }

          const hidden = ensureHiddenInput();
          if (hidden) hidden.value = item.id;
          resultsBox.style.display = 'none';
          if (input.form && input.form.classList.contains('filter_form')) {
            input.form.submit();
          }
        };

        data.forEach(item => {
          const li = document.createElement('li');
          li.innerHTML = renderItem(item);
          li.addEventListener('click', () => handleClick(item));
          resultsBox.appendChild(li);
        });

        resultsBox.style.display = 'block';
      });
  });

  // Schließe Results beim Klick außerhalb
  document.addEventListener('click', (e) => {
    if (!resultsBox.contains(e.target) && e.target !== input) {
      resultsBox.style.display = 'none';
    }
  });
}

// Beim ersten Laden: alle vorhandenen Felder initialisieren
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.admin-autocomplete-component').forEach(initAdminAutocompleteInput);

  // MutationObserver: prüft, ob neue Felder ins Formular eingefügt werden
  const form = document.querySelector('form');
  if (!form) return;
  const observer = new MutationObserver(mutations => {
    for (const mutation of mutations) {
      mutation.addedNodes.forEach(node => {
        if (node.nodeType !== 1) return; // Nur Element-Nodes
        // Falls ein kompletter Block (z.B. fieldset/li/div) mit Autocomplete-Feld drin eingefügt wird
        node.querySelectorAll?.('.admin-autocomplete-component').forEach(initAdminAutocompleteInput);

        // Oder falls das direkte Node selbst ein Autocomplete-Input ist
        if (node.classList?.contains('admin-autocomplete-component')) {
          initAdminAutocompleteInput(node);
        }
      });
    }
  });
  observer.observe(form, { childList: true, subtree: true });
});

function resetHiddenIfEmpty(input) {
  if (input.value.trim() !== "") return;

  // Alle bekannten Autocomplete-IDs prüfen (user, location, …)
  ["userAutocompleteId", "locationAutocompleteId"].forEach(attr => {
    const autocompleteId = input.dataset[attr];
    if (autocompleteId) {
      const hiddenInput = input.form.querySelector(
        `.admin-autocomplete-id-target[data-${attr.replace("AutocompleteId", "").toLowerCase()}-autocomplete-id="${autocompleteId}"]`
      );
      if (hiddenInput) hiddenInput.value = "";
    }
  });
}
