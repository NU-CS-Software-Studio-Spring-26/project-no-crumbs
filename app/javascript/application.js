// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.config.forms.confirm = (message) => {
  return new Promise((resolve) => {
    const backdrop = document.createElement("div");
    backdrop.className = "nc-modal-backdrop";
    backdrop.innerHTML = `
      <div class="nc-modal" role="dialog" aria-modal="true">
        <div class="nc-modal-header">
          <div class="nc-modal-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M19 6l-1 14H6L5 6M10 11v6M14 11v6M9 6V4h6v2"/></svg>
          </div>
          <p class="nc-modal-title">Are you sure?</p>
          <p class="nc-modal-message">${message}</p>
        </div>
        <div class="nc-modal-footer">
          <button class="btn-outline-nc btn-sm-nc" id="nc-modal-cancel">Cancel</button>
          <button class="btn-danger-nc btn-sm-nc" id="nc-modal-confirm">Delete</button>
        </div>
      </div>
    `;

    document.body.appendChild(backdrop);

    const cleanup = (result) => {
      backdrop.remove();
      resolve(result);
    };

    backdrop.querySelector("#nc-modal-confirm").addEventListener("click", () => cleanup(true));
    backdrop.querySelector("#nc-modal-cancel").addEventListener("click", () => cleanup(false));
    backdrop.addEventListener("click", (e) => { if (e.target === backdrop) cleanup(false); });
  });
};
