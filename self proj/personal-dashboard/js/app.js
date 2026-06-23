/* ============================================
   TaskMind — App Controller (Pro Version)
   Routing, init, toast, navigation, shortcuts
   ============================================ */

const App = (() => {
  let currentPage = 'board';

  // --- Initialize ---
  function init() {
    setupNavigation();
    setupModalCloseHandlers();
    setupImportExport();
    setupKeyboardShortcuts();

    // Route from hash
    const hash = window.location.hash.slice(1) || 'board';
    navigateTo(hash);

    // Init modules
    TaskBoard.init();
    Dashboard.init();
    Settings.init();
    Reminder.init();

    // Log visit
    Storage.setLastVisit();

    console.log(
      '%c🧠 TaskMind Pro initialized!',
      'background: linear-gradient(135deg, #6c5ce7, #a29bfe); color: white; padding: 8px 16px; border-radius: 8px; font-size: 14px; font-weight: bold;'
    );
  }

  // --- Navigation ---
  function setupNavigation() {
    document.querySelectorAll('.nav-link[data-page]').forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const page = link.dataset.page;
        navigateTo(page);
      });
    });

    window.addEventListener('hashchange', () => {
      const hash = window.location.hash.slice(1) || 'board';
      navigateTo(hash, false);
    });
  }

  function navigateTo(page, updateHash = true) {
    currentPage = page;

    // Update nav active state
    document.querySelectorAll('.nav-link[data-page]').forEach(link => {
      link.classList.toggle('active', link.dataset.page === page);
    });

    // Show/hide pages
    document.querySelectorAll('.page').forEach(p => {
      p.classList.toggle('active', p.id === `page-${page}`);
    });

    // Update hash
    if (updateHash) {
      window.location.hash = page;
    }

    // Refresh active page
    if (page === 'dashboard') Dashboard.refresh();
    if (page === 'board') TaskBoard.renderAllTasks();
    if (page === 'settings') Settings.renderSettings();
  }

  // --- Modal Handlers ---
  function setupModalCloseHandlers() {
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
      overlay.addEventListener('click', (e) => {
        if (e.target === overlay) overlay.classList.remove('active');
      });
    });

    document.querySelectorAll('.modal-close').forEach(btn => {
      btn.addEventListener('click', () => {
        const modal = btn.closest('.modal-overlay');
        if (modal) modal.classList.remove('active');
      });
    });
  }

  // --- Keyboard Shortcuts ---
  function setupKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
      // Escape - close modals
      if (e.key === 'Escape') {
        document.querySelectorAll('.modal-overlay.active').forEach(m => m.classList.remove('active'));
        TaskBoard.closeAllDropdowns();
      }

      // Ctrl+N - new task
      if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
        e.preventDefault();
        TaskBoard.openAddModal();
      }

      // Ctrl+1/2/3 - switch pages
      if ((e.ctrlKey || e.metaKey) && e.key === '1') {
        e.preventDefault();
        navigateTo('board');
      }
      if ((e.ctrlKey || e.metaKey) && e.key === '2') {
        e.preventDefault();
        navigateTo('dashboard');
      }
      if ((e.ctrlKey || e.metaKey) && e.key === '3') {
        e.preventDefault();
        navigateTo('settings');
      }

      // Ctrl+/ - toggle search focus
      if ((e.ctrlKey || e.metaKey) && e.key === '/') {
        e.preventDefault();
        const searchInput = document.getElementById('search-input');
        if (searchInput) {
          navigateTo('board');
          setTimeout(() => searchInput.focus(), 100);
        }
      }
    });
  }

  // --- Import / Export ---
  function setupImportExport() {
    // Board page buttons
    setupImportExportPair('export-btn', 'import-btn', 'import-input');
    // Settings page buttons
    setupImportExportPair('settings-export-btn', 'settings-import-btn', 'settings-import-input');
  }

  function setupImportExportPair(exportId, importId, inputId) {
    const exportBtn = document.getElementById(exportId);
    const importBtn = document.getElementById(importId);
    const importInput = document.getElementById(inputId);

    if (exportBtn) {
      exportBtn.addEventListener('click', () => {
        Storage.exportData();
        showToast('💾 Đã xuất backup!', 'success');
      });
    }

    if (importBtn && importInput) {
      importBtn.addEventListener('click', () => importInput.click());
      importInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (ev) => {
          const result = Storage.importData(ev.target.result);
          if (result.success) {
            showToast(`📂 Đã import ${result.taskCount} tasks!`, 'success');
            TaskBoard.renderAllTasks();
            Dashboard.refresh();
            Settings.renderSettings();
          } else {
            showToast(`Import lỗi: ${result.error}`, 'danger');
          }
        };
        reader.readAsText(file);
        importInput.value = '';
      });
    }
  }

  // --- Toast Notifications ---
  function showToast(message, type = 'info', duration = 4000) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const icons = { success: '✅', danger: '❌', warning: '⚠️', info: 'ℹ️' };

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
      <span class="toast-icon">${icons[type] || 'ℹ️'}</span>
      <span>${message}</span>
    `;

    container.appendChild(toast);

    setTimeout(() => {
      toast.classList.add('toast-exit');
      setTimeout(() => toast.remove(), 300);
    }, duration);
  }

  function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove('active');
  }

  return {
    init,
    navigateTo,
    showToast,
    closeModal,
  };
})();

// --- Boot ---
document.addEventListener('DOMContentLoaded', () => {
  App.init();
});
