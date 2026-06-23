/* ============================================
   TaskMind — Settings Module
   Customizable preferences, category management
   ============================================ */

const Settings = (() => {
  function init() {
    renderSettings();
    setupEventListeners();
  }

  function renderSettings() {
    const settings = Storage.loadSettings();
    const tasks = Storage.loadTasks();

    // Notification toggle
    const notifToggle = document.getElementById('setting-notifications');
    if (notifToggle) notifToggle.checked = settings.notificationsEnabled;

    // Forgotten days
    const forgottenInput = document.getElementById('setting-forgotten-days');
    if (forgottenInput) forgottenInput.value = settings.forgottenDays;

    // Idle minutes
    const idleInput = document.getElementById('setting-idle-minutes');
    if (idleInput) idleInput.value = settings.idleMinutes;

    // Render categories
    renderCategories(settings, tasks);

    // Data stats
    renderDataStats(tasks);
  }

  function renderCategories(settings, tasks) {
    const container = document.getElementById('category-list');
    if (!container) return;

    const categories = settings.categories || ['Work', 'Personal', 'Learning', 'Other'];
    const categoryColors = {
      Work: '#6c5ce7',
      Personal: '#00b894',
      Learning: '#fdcb6e',
      Other: '#e17055',
    };
    const categoryIcons = {
      Work: '💼',
      Personal: '🏠',
      Learning: '📚',
      Other: '📌',
    };

    // Count tasks per category
    const counts = {};
    tasks.forEach(t => {
      counts[t.category] = (counts[t.category] || 0) + 1;
    });

    container.innerHTML = categories.map(cat => {
      const color = categoryColors[cat] || '#b2bec3';
      const icon = categoryIcons[cat] || '📌';
      const count = counts[cat] || 0;
      const isDefault = ['Work', 'Personal', 'Learning', 'Other'].includes(cat);

      return `
        <div class="category-item" data-category="${cat}">
          <span class="category-item-color" style="background: ${color}"></span>
          <span class="category-item-name">${icon} ${cat}</span>
          <span class="category-item-count">${count} task${count !== 1 ? 's' : ''}</span>
          ${!isDefault ? `
            <button class="category-item-delete" onclick="Settings.removeCategory('${cat}')" title="Xóa">✕</button>
          ` : ''}
        </div>
      `;
    }).join('');
  }

  function renderDataStats(tasks) {
    const el = document.getElementById('data-stats');
    if (!el) return;

    const total = tasks.length;
    const activity = Storage.loadActivity();
    const streak = Storage.getStreak();

    el.textContent = `${total} tasks · ${activity.length} hoạt động · Streak: ${streak.count} ngày`;
  }

  function setupEventListeners() {
    // Forgotten days
    const forgottenInput = document.getElementById('setting-forgotten-days');
    if (forgottenInput) {
      forgottenInput.addEventListener('change', (e) => {
        const val = Math.max(1, Math.min(30, parseInt(e.target.value) || 2));
        e.target.value = val;
        const settings = Storage.loadSettings();
        settings.forgottenDays = val;
        Storage.saveSettings(settings);
        App.showToast(`Ngưỡng quên: ${val} ngày`, 'success');
        refreshOtherModules();
      });
    }

    // Idle minutes
    const idleInput = document.getElementById('setting-idle-minutes');
    if (idleInput) {
      idleInput.addEventListener('change', (e) => {
        const val = Math.max(5, Math.min(120, parseInt(e.target.value) || 30));
        e.target.value = val;
        const settings = Storage.loadSettings();
        settings.idleMinutes = val;
        Storage.saveSettings(settings);
        App.showToast(`Nhắc idle: ${val} phút`, 'success');
      });
    }

    // Notifications toggle
    const notifToggle = document.getElementById('setting-notifications');
    if (notifToggle) {
      notifToggle.addEventListener('change', (e) => {
        const settings = Storage.loadSettings();
        settings.notificationsEnabled = e.target.checked;
        Storage.saveSettings(settings);

        if (e.target.checked) {
          Reminder.requestNotificationPermission();
          App.showToast('🔔 Đã bật thông báo', 'success');
        } else {
          App.showToast('🔕 Đã tắt thông báo', 'info');
        }
      });
    }

    // Add category
    const addCatBtn = document.getElementById('add-category-btn');
    const addCatInput = document.getElementById('add-category-input');
    if (addCatBtn && addCatInput) {
      addCatBtn.addEventListener('click', () => addCategory(addCatInput));
      addCatInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') addCategory(addCatInput);
      });
    }

    // Clear all data
    const clearBtn = document.getElementById('clear-all-data');
    if (clearBtn) {
      clearBtn.addEventListener('click', clearAllData);
    }
  }

  function addCategory(input) {
    const name = input.value.trim();
    if (!name) return;

    const settings = Storage.loadSettings();
    if (settings.categories.includes(name)) {
      App.showToast('Category đã tồn tại!', 'warning');
      return;
    }

    settings.categories.push(name);
    Storage.saveSettings(settings);
    input.value = '';
    renderSettings();
    App.showToast(`Đã thêm category "${name}"`, 'success');

    // Update task form select
    updateCategorySelects(settings.categories);
  }

  function removeCategory(name) {
    const tasks = Storage.loadTasks();
    const tasksWithCat = tasks.filter(t => t.category === name);

    if (tasksWithCat.length > 0) {
      if (!confirm(`Category "${name}" có ${tasksWithCat.length} task. Chuyển tất cả sang "Other"?`)) return;

      tasksWithCat.forEach(t => {
        Storage.updateTask(t.id, { category: 'Other' });
      });
    }

    const settings = Storage.loadSettings();
    settings.categories = settings.categories.filter(c => c !== name);
    Storage.saveSettings(settings);
    renderSettings();
    App.showToast(`Đã xóa category "${name}"`, 'info');

    updateCategorySelects(settings.categories);
    refreshOtherModules();
  }

  function updateCategorySelects(categories) {
    const categoryIcons = {
      Work: '💼', Personal: '🏠', Learning: '📚', Other: '📌',
    };
    const select = document.getElementById('task-category-input');
    if (!select) return;

    const currentVal = select.value;
    select.innerHTML = categories.map(cat => {
      const icon = categoryIcons[cat] || '📌';
      return `<option value="${cat}">${icon} ${cat}</option>`;
    }).join('');

    if (categories.includes(currentVal)) {
      select.value = currentVal;
    }
  }

  function clearAllData() {
    if (!confirm('⚠️ XÓA TẤT CẢ dữ liệu?\n\nHành động này KHÔNG thể hoàn tác!\nHãy Export backup trước nếu cần.')) return;
    if (!confirm('Bạn chắc chắn chứ? Toàn bộ tasks, activity, streak sẽ bị xóa vĩnh viễn.')) return;

    localStorage.clear();
    App.showToast('Đã xóa toàn bộ dữ liệu!', 'danger');

    setTimeout(() => window.location.reload(), 1000);
  }

  function refreshOtherModules() {
    if (typeof TaskBoard !== 'undefined') TaskBoard.renderAllTasks();
    if (typeof Dashboard !== 'undefined') Dashboard.refresh();
    if (typeof Reminder !== 'undefined') Reminder.checkTasks();
  }

  return {
    init,
    renderSettings,
    removeCategory,
    addCategory,
    updateCategorySelects,
  };
})();
