document.addEventListener('DOMContentLoaded', () => {
  const inputs = document.querySelectorAll('.admin-autocomplete-component');

  inputs.forEach(input => {
    const url = input.dataset.autocompleteUrl;
    const targetName = input.dataset.targetInput;

    const resultsBox = document.createElement('ul');
    resultsBox.classList.add('admin-autocomplete-results');
    input.parentNode.appendChild(resultsBox);    
    input.parentNode.classList.add('admin-autocomplete-container');

    const ensureHiddenInput = () => {
      let hidden = document.querySelector(`input[name="${targetName}"]`);
      if (!hidden) {
        hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = targetName;
        input.form.appendChild(hidden);
      }
      return hidden;
    };

    input.addEventListener('input', () => {
      const q = input.value.trim();
      if (q.length < 4) {
        resultsBox.innerHTML = '';
        resultsBox.style.display = 'none';
        return;
      }

      fetch(`${url}?q=${encodeURIComponent(q)}`)
        .then(res => res.json())
        .then(data => {
          resultsBox.innerHTML = '';
          data.forEach(item => {
            const li = document.createElement('li');
            li.innerHTML = `
              <div class="eac-item">
                <div class="item User">
                  <img src="${item.image_url}">
                  <div class="txt">${item.full_name} (${item.username})<br><span>(${item.email})</span></div>
                </div>
              </div>
            `;
            li.addEventListener('click', () => {
              input.value = item.username;
              ensureHiddenInput().value = item.id;
              //resultsBox.style.display = 'none';
              // Nur submitten, wenn das Formular eine Filter-Form ist
              if (input.form && input.form.classList.contains('filter_form')) {
                input.form.submit();
              }
            });
            resultsBox.appendChild(li);
          });
          resultsBox.style.display = 'block';
        });
    });

    document.addEventListener('click', (e) => {
      if (!resultsBox.contains(e.target) && e.target !== input) {
        resultsBox.style.display = 'none';
      }
    });
  });
});
