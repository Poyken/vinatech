/* ============================================
   TaskMind — Task Board Logic (Pro Version)
   CRUD, Drag & Drop, Sort, List View, Stats
   ============================================ */

const TaskBoard = (() => {
  let currentFilter = 'all';
  let currentSearch = '';
  let currentSort = 'smart';
  let currentView = 'board';
  let activeDropdown = null;

  // --- Initialize ---
  function init() {
    seedDemoTasksIfEmpty();
    renderAllTasks();
    setupDragAndDrop();
    setupEventListeners();
    updateQuickStats();
  }

  // --- Demo Tasks ---
  function seedDemoTasksIfEmpty() {
    const tasks = Storage.loadTasks();
    if (tasks.length > 0) return;

    const now = Date.now();
    const day = 86400000;

    const demoTasks = [
      {
        id: Storage.generateId(), title: 'Thiết kế wireframe cho app mới',
        description: 'Dùng Figma tạo wireframe cho 5 màn hình chính: Home, Profile, Settings, Dashboard, Detail.',
        category: 'Work', priority: 'high', status: 'doing',
        deadline: new Date(now + 2 * day).toISOString().slice(0, 16),
        createdAt: now - 5 * day, updatedAt: now - 3 * day, completedAt: null,
      },
      {
        id: Storage.generateId(), title: 'Review pull request #42',
        description: 'Team member gửi PR sửa bug authentication, cần review code và test.',
        category: 'Work', priority: 'medium', status: 'todo',
        deadline: new Date(now + 1 * day).toISOString().slice(0, 16),
        createdAt: now - 1 * day, updatedAt: now - 1 * day, completedAt: null,
      },
      {
        id: Storage.generateId(), title: 'Học React Server Components',
        description: 'Xem video tutorial và thực hành với Next.js App Router. Ghi chú lại kiến thức.',
        category: 'Learning', priority: 'medium', status: 'doing',
        deadline: null, createdAt: now - 7 * day, updatedAt: now, completedAt: null,
      },
      {
        id: Storage.generateId(), title: 'Mua quà sinh nhật cho em',
        description: 'Tìm quà ý nghĩa, budget khoảng 500k-1tr.',
        category: 'Personal', priority: 'high', status: 'todo',
        deadline: new Date(now + 5 * day).toISOString().slice(0, 16),
        createdAt: now, updatedAt: now, completedAt: null,
      },
      {
        id: Storage.generateId(), title: 'Setup CI/CD pipeline',
        description: 'Cấu hình GitHub Actions cho auto deploy khi merge vào main.',
        category: 'Work', priority: 'low', status: 'todo',
        deadline: null, createdAt: now - 2 * day, updatedAt: now - 2 * day, completedAt: null,
      },
      {
        id: Storage.generateId(), title: 'Chạy bộ 5km',
        description: 'Duy trì thói quen chạy bộ buổi sáng.',
        category: 'Personal', priority: 'low', status: 'done',
        deadline: null, createdAt: now - 3 * day, updatedAt: now - 1 * day, completedAt: now - 1 * day,
      },
      {
        id: Storage.generateId(), title: 'Viết blog về TypeScript tips',
        description: 'Chia sẻ 10 mẹo TypeScript hữu ích cho dev Việt Nam.',
        category: 'Learning', priority: 'medium', status: 'doing',
        deadline: new Date(now + 7 * day).toISOString().slice(0, 16),
        createdAt: now - 4 * day, updatedAt: now - 3.5 * day, completedAt: null,
      },
      {
        id: Storage.generateId(), title: 'Fix bug hiển thị trên mobile',
        description: 'Layout bị vỡ trên iPhone SE, cần test và sửa responsive.',
        category: 'Work', priority: 'high', status: 'done',
        deadline: null, createdAt: now - 5 * day, updatedAt: now - 2 * day, completedAt: now - 2 * day,
      },
    ];

    Storage.saveTasks(demoTasks);
    demoTasks.forEach(t => Storage.logActivity('created', t));
  }

  // --- Sort ---
  function sortTasks(tasks) {
    const settings = Storage.loadSettings();
    const now = Date.now();

    return [...tasks].sort((a, b) => {
      switch (currentSort) {
        case 'smart': {
          // Forgotten first, then priority, then deadline proximity
          const aForgotten = a.status === 'doing' && (now - a.updatedAt) / 86400000 > settings.forgottenDays;
          const bForgotten = b.status === 'doing' && (now - b.updatedAt) / 86400000 > settings.forgottenDays;
          if (aForgotten && !bForgotten) return -1;
          if (!aForgotten && bForgotten) return 1;

          const po = { high: 0, medium: 1, low: 2 };
          const pd = (po[a.priority] || 2) - (po[b.priority] || 2);
          if (pd !== 0) return pd;

          // Deadline proximity
          const aDeadline = a.deadline ? new Date(a.deadline).getTime() : Infinity;
          const bDeadline = b.deadline ? new Date(b.deadline).getTime() : Infinity;
          return aDeadline - bDeadline;
        }
        case 'priority': {
          const po = { high: 0, medium: 1, low: 2 };
          return (po[a.priority] || 2) - (po[b.priority] || 2);
        }
        case 'newest':
          return b.createdAt - a.createdAt;
        case 'oldest':
          return a.createdAt - b.createdAt;
        case 'deadline': {
          const aD = a.deadline ? new Date(a.deadline).getTime() : Infinity;
          const bD = b.deadline ? new Date(b.deadline).getTime() : Infinity;
          return aD - bD;
        }
        case 'alpha':
          return a.title.localeCompare(b.title, 'vi');
        default:
          return 0;
      }
    });
  }

  // --- Render ---
  function renderAllTasks() {
    const tasks = Storage.loadTasks();
    const filtered = filterTasks(tasks);

    if (currentView === 'board') {
      renderColumn('todo', filtered.filter(t => t.status === 'todo'));
      renderColumn('doing', filtered.filter(t => t.status === 'doing'));
      renderColumn('done', filtered.filter(t => t.status === 'done'));
    } else {
      renderListView(filtered);
    }

    updateColumnCounts(tasks);
    updateColumnProgress(tasks);
    updateQuickStats();
  }

  function renderColumn(status, tasks) {
    const container = document.querySelector(`.column-tasks[data-status="${status}"]`);
    if (!container) return;

    const sorted = sortTasks(tasks);

    const emptyMessages = {
      todo: { icon: '📝', text: 'Thêm task mới để bắt đầu!' },
      doing: { icon: '🚀', text: 'Kéo task từ "To Do" sang đây' },
      done: { icon: '🎉', text: 'Task hoàn thành sẽ ở đây' },
    };

    if (sorted.length === 0) {
      const msg = emptyMessages[status] || { icon: '📋', text: 'Trống' };
      container.innerHTML = `
        <div class="empty-state">
          <div class="empty-state-icon">${msg.icon}</div>
          <div class="empty-state-text">${msg.text}</div>
        </div>
      `;
      return;
    }

    container.innerHTML = sorted.map(task => createTaskCard(task)).join('');

    container.querySelectorAll('.task-card').forEach(card => {
      card.addEventListener('dragstart', handleDragStart);
      card.addEventListener('dragend', handleDragEnd);
    });
  }

  function createTaskCard(task) {
    const settings = Storage.loadSettings();
    const now = Date.now();
    const isForgotten = task.status === 'doing' && (now - task.updatedAt) / 86400000 > settings.forgottenDays;
    const forgottenDays = Math.floor((now - task.updatedAt) / 86400000);
    const isOverdue = task.deadline && task.status !== 'done' && new Date(task.deadline) < now;

    const classes = ['task-card', isForgotten ? 'forgotten' : '', isOverdue ? 'overdue' : ''].filter(Boolean).join(' ');
    const catClass = `task-category-${task.category.toLowerCase()}`;

    return `
      <div class="${classes}" data-id="${task.id}" data-priority="${task.priority}" draggable="true">
        <div class="task-card-header">
          <div class="task-title">${escapeHtml(task.title)}</div>
          <div class="task-card-menu">
            <button class="task-card-menu-btn" onclick="TaskBoard.toggleDropdown(event, '${task.id}')" title="Menu">⋯</button>
            <div class="task-dropdown" id="dropdown-${task.id}">
              <button class="task-dropdown-item" onclick="TaskBoard.editTask('${task.id}')">✏️ Chỉnh sửa</button>
              <button class="task-dropdown-item" onclick="TaskBoard.touchTask('${task.id}')">👋 Đã xem lại</button>
              <button class="task-dropdown-item danger" onclick="TaskBoard.confirmDeleteTask('${task.id}')">🗑️ Xóa task</button>
            </div>
          </div>
        </div>
        ${task.description ? `<div class="task-description">${escapeHtml(task.description)}</div>` : ''}
        <div class="task-meta">
          <div class="task-tags">
            <span class="task-category ${catClass}">${getCategoryIcon(task.category)} ${escapeHtml(task.category)}</span>
            <span class="task-priority task-priority-${task.priority}">${getPriorityLabel(task.priority)}</span>
          </div>
          <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap;">
            ${task.deadline ? `<span class="task-deadline">📅 ${formatDeadline(task.deadline)}</span>` : ''}
            ${isForgotten ? `<span class="task-forgotten-days">🔥 ${forgottenDays} ngày</span>` : ''}
          </div>
        </div>
      </div>
    `;
  }

  // --- List View ---
  function renderListView(tasks) {
    const container = document.getElementById('list-view');
    if (!container) return;

    const groups = [
      { key: 'doing', label: '🚀 Đang làm', dot: 'column-dot-doing' },
      { key: 'todo', label: '📝 To Do', dot: 'column-dot-todo' },
      { key: 'done', label: '✅ Hoàn thành', dot: 'column-dot-done' },
    ];

    let html = '';
    groups.forEach(group => {
      const groupTasks = sortTasks(tasks.filter(t => t.status === group.key));
      html += `
        <div class="list-group">
          <div class="list-group-header">
            <span class="column-dot ${group.dot}"></span>
            <span class="list-group-title">${group.label}</span>
            <span class="list-group-count">${groupTasks.length}</span>
          </div>
          ${groupTasks.length === 0 ? `
            <div class="empty-state" style="padding: var(--space-lg);">
              <div class="empty-state-text">Không có task</div>
            </div>
          ` : groupTasks.map(task => createListItem(task)).join('')}
        </div>
      `;
    });

    container.innerHTML = html;
  }

  function createListItem(task) {
    const settings = Storage.loadSettings();
    const now = Date.now();
    const isForgotten = task.status === 'doing' && (now - task.updatedAt) / 86400000 > settings.forgottenDays;
    const catClass = `task-category-${task.category.toLowerCase()}`;
    const classes = ['list-task-item', isForgotten ? 'forgotten' : ''].filter(Boolean).join(' ');

    const deadlineText = task.deadline ? formatDeadline(task.deadline) : '';

    return `
      <div class="${classes}" data-id="${task.id}">
        <span class="list-task-priority-dot ${task.priority}"></span>
        <div class="list-task-info">
          <div class="list-task-title">${escapeHtml(task.title)}</div>
          <div class="list-task-subtitle">
            <span class="task-category ${catClass}" style="font-size:0.65rem;padding:2px 7px;">${getCategoryIcon(task.category)} ${task.category}</span>
            ${deadlineText ? `<span>📅 ${deadlineText}</span>` : ''}
            ${isForgotten ? `<span style="color:var(--color-danger);font-weight:600;">⚠️ Quên</span>` : ''}
          </div>
        </div>
        <div class="list-task-actions">
          <button class="list-action-btn" onclick="TaskBoard.editTask('${task.id}')" title="Chỉnh sửa">✏️</button>
          <button class="list-action-btn danger" onclick="TaskBoard.confirmDeleteTask('${task.id}')" title="Xóa">🗑️</button>
        </div>
      </div>
    `;
  }

  // --- Quick Stats ---
  function updateQuickStats() {
    const tasks = Storage.loadTasks();
    const settings = Storage.loadSettings();
    const now = Date.now();

    const total = tasks.length;
    const done = tasks.filter(t => t.status === 'done').length;
    const forgotten = tasks.filter(t => t.status === 'doing' && (now - t.updatedAt) / 86400000 > settings.forgottenDays).length;
    const overdue = tasks.filter(t => t.status !== 'done' && t.deadline && new Date(t.deadline) < now).length;

    const el = (id) => document.getElementById(id);
    if (el('qs-total')) el('qs-total').textContent = total;
    if (el('qs-done')) el('qs-done').textContent = done;
    if (el('qs-forgotten')) el('qs-forgotten').textContent = forgotten;
    if (el('qs-overdue')) el('qs-overdue').textContent = overdue;
  }

  // --- Column Progress ---
  function updateColumnProgress(tasks) {
    const total = tasks.length || 1;
    ['todo', 'doing', 'done'].forEach(status => {
      const count = tasks.filter(t => t.status === status).length;
      const pct = Math.round((count / total) * 100);
      const bar = document.querySelector(`.column-progress-bar[data-status="${status}"]`);
      if (bar) bar.style.width = `${pct}%`;
    });
  }

  function updateColumnCounts(tasks) {
    const counts = { todo: 0, doing: 0, done: 0 };
    tasks.forEach(t => { if (counts[t.status] !== undefined) counts[t.status]++; });
    Object.entries(counts).forEach(([status, count]) => {
      const el = document.querySelector(`.column-count[data-status="${status}"]`);
      if (el) el.textContent = count;
    });
  }

  // --- Filter ---
  function filterTasks(tasks) {
    let result = tasks;
    if (currentFilter !== 'all') {
      result = result.filter(t => t.category.toLowerCase() === currentFilter.toLowerCase());
    }
    if (currentSearch.trim()) {
      const q = currentSearch.toLowerCase().trim();
      result = result.filter(t => t.title.toLowerCase().includes(q) || (t.description && t.description.toLowerCase().includes(q)));
    }
    return result;
  }

  function setFilter(filter) {
    currentFilter = filter;
    document.querySelectorAll('.filter-pill').forEach(pill => {
      pill.classList.toggle('active', pill.dataset.filter === filter);
    });
    renderAllTasks();
  }

  function setSearch(query) {
    currentSearch = query;
    renderAllTasks();
  }

  function setSort(sort) {
    currentSort = sort;
    document.querySelectorAll('.sort-option').forEach(opt => {
      opt.classList.toggle('active', opt.dataset.sort === sort);
    });
    closeSortDropdown();
    renderAllTasks();
  }

  function setView(view) {
    currentView = view;
    const board = document.getElementById('kanban-board');
    const list = document.getElementById('list-view');

    document.querySelectorAll('.view-toggle-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.view === view);
    });

    if (view === 'board') {
      if (board) board.classList.remove('hidden');
      if (list) list.classList.remove('active');
    } else {
      if (board) board.classList.add('hidden');
      if (list) list.classList.add('active');
    }

    renderAllTasks();
  }

  // --- CRUD ---
  function openAddModal(defaultStatus = 'todo') {
    const modal = document.getElementById('task-modal');
    const form = document.getElementById('task-form');
    const title = document.getElementById('modal-title');

    title.textContent = '✨ Thêm task mới';
    form.reset();
    document.getElementById('task-id').value = '';
    document.getElementById('task-status').value = defaultStatus;

    // Update category options from settings
    const settings = Storage.loadSettings();
    if (typeof Settings !== 'undefined') {
      Settings.updateCategorySelects(settings.categories);
    }

    modal.classList.add('active');
    setTimeout(() => document.getElementById('task-title-input').focus(), 150);
  }

  function editTask(id) {
    closeAllDropdowns();
    const task = Storage.getTask(id);
    if (!task) return;

    const modal = document.getElementById('task-modal');
    const title = document.getElementById('modal-title');

    title.textContent = '✏️ Chỉnh sửa task';
    document.getElementById('task-id').value = task.id;
    document.getElementById('task-title-input').value = task.title;
    document.getElementById('task-description-input').value = task.description || '';
    document.getElementById('task-category-input').value = task.category;
    document.getElementById('task-priority-input').value = task.priority;
    document.getElementById('task-deadline-input').value = task.deadline || '';
    document.getElementById('task-status').value = task.status;

    modal.classList.add('active');
    setTimeout(() => document.getElementById('task-title-input').focus(), 150);
  }

  function saveTask() {
    const id = document.getElementById('task-id').value;
    const title = document.getElementById('task-title-input').value.trim();
    const description = document.getElementById('task-description-input').value.trim();
    const category = document.getElementById('task-category-input').value;
    const priority = document.getElementById('task-priority-input').value;
    const deadline = document.getElementById('task-deadline-input').value;
    const status = document.getElementById('task-status').value;

    if (!title) {
      document.getElementById('task-title-input').focus();
      document.getElementById('task-title-input').style.borderColor = 'var(--color-danger)';
      setTimeout(() => { document.getElementById('task-title-input').style.borderColor = ''; }, 2000);
      App.showToast('Vui lòng nhập tên task!', 'danger');
      return;
    }

    if (id) {
      Storage.updateTask(id, { title, description, category, priority, deadline: deadline || null, status });
      App.showToast('✅ Đã cập nhật task!', 'success');
    } else {
      const newTask = {
        id: Storage.generateId(), title, description, category, priority, status,
        deadline: deadline || null, createdAt: Date.now(), updatedAt: Date.now(), completedAt: null,
      };
      Storage.addTask(newTask);
      App.showToast('🎉 Đã thêm task mới!', 'success');
    }

    closeModal('task-modal');
    renderAllTasks();
    if (typeof Dashboard !== 'undefined') Dashboard.refresh();
    if (typeof Reminder !== 'undefined') Reminder.checkTasks();
  }

  function confirmDeleteTask(id) {
    closeAllDropdowns();
    const task = Storage.getTask(id);
    if (!task) return;
    if (confirm(`Xóa task "${task.title}"?\n\nThao tác này không thể hoàn tác.`)) {
      Storage.deleteTask(id);
      renderAllTasks();
      App.showToast('🗑️ Đã xóa task!', 'info');
      if (typeof Dashboard !== 'undefined') Dashboard.refresh();
    }
  }

  function touchTask(id) {
    closeAllDropdowns();
    Storage.updateTask(id, {});
    renderAllTasks();
    App.showToast('👋 Đã cập nhật — task không còn bị coi là quên!', 'success');
  }

  // --- Dropdown ---
  function toggleDropdown(event, id) {
    event.stopPropagation();
    const dropdown = document.getElementById(`dropdown-${id}`);
    if (!dropdown) return;
    const isActive = dropdown.classList.contains('active');
    closeAllDropdowns();
    if (!isActive) { dropdown.classList.add('active'); activeDropdown = dropdown; }
  }

  function closeAllDropdowns() {
    document.querySelectorAll('.task-dropdown.active').forEach(d => d.classList.remove('active'));
    activeDropdown = null;
  }

  function closeSortDropdown() {
    const dd = document.getElementById('sort-dropdown');
    if (dd) dd.classList.remove('active');
  }

  // --- Drag & Drop ---
  let draggedCard = null;
  let draggedTaskId = null;

  function setupDragAndDrop() {
    document.querySelectorAll('.column-tasks').forEach(column => {
      column.addEventListener('dragover', handleDragOver);
      column.addEventListener('dragenter', handleDragEnter);
      column.addEventListener('dragleave', handleDragLeave);
      column.addEventListener('drop', handleDrop);
    });
  }

  function handleDragStart(e) {
    draggedCard = e.target.closest('.task-card');
    draggedTaskId = draggedCard?.dataset?.id;
    if (!draggedCard) return;
    draggedCard.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', draggedTaskId);
    setTimeout(() => { if (draggedCard) draggedCard.style.opacity = '0.35'; }, 0);
  }

  function handleDragEnd() {
    if (draggedCard) { draggedCard.classList.remove('dragging'); draggedCard.style.opacity = ''; }
    draggedCard = null; draggedTaskId = null;
    document.querySelectorAll('.kanban-column.drag-over').forEach(col => col.classList.remove('drag-over'));
  }

  function handleDragOver(e) { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; }

  function handleDragEnter(e) {
    e.preventDefault();
    const column = e.target.closest('.kanban-column');
    if (column) {
      document.querySelectorAll('.kanban-column.drag-over').forEach(c => c.classList.remove('drag-over'));
      column.classList.add('drag-over');
    }
  }

  function handleDragLeave(e) {
    const column = e.target.closest('.kanban-column');
    if (column && !column.contains(e.relatedTarget)) column.classList.remove('drag-over');
  }

  function handleDrop(e) {
    e.preventDefault();
    const column = e.target.closest('.kanban-column');
    if (!column || !draggedTaskId) return;
    column.classList.remove('drag-over');
    const newStatus = column.querySelector('.column-tasks')?.dataset?.status;
    if (!newStatus) return;
    const task = Storage.getTask(draggedTaskId);
    if (task && task.status !== newStatus) {
      Storage.moveTask(draggedTaskId, newStatus);
      renderAllTasks();
      const names = { todo: '📝 To Do', doing: '🚀 Đang làm', done: '✅ Hoàn thành' };
      App.showToast(`Di chuyển → ${names[newStatus]}`, 'success');
      if (newStatus === 'done') {
        Storage.updateStreak();
        setTimeout(() => App.showToast('🎉 Tuyệt vời! Task hoàn thành!', 'success'), 800);
      }
      if (typeof Dashboard !== 'undefined') Dashboard.refresh();
      if (typeof Reminder !== 'undefined') Reminder.checkTasks();
    }
  }

  // --- Event Listeners ---
  function setupEventListeners() {
    // Close dropdowns on outside click
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.task-card-menu')) closeAllDropdowns();
      if (!e.target.closest('.sort-dropdown-container')) closeSortDropdown();
    });

    // Search
    const searchInput = document.getElementById('search-input');
    if (searchInput) {
      let searchTimeout;
      searchInput.addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => setSearch(e.target.value), 200);
      });
    }

    // Filters
    document.querySelectorAll('.filter-pill').forEach(pill => {
      pill.addEventListener('click', () => setFilter(pill.dataset.filter));
    });

    // Save button
    const saveBtn = document.getElementById('save-task-btn');
    if (saveBtn) saveBtn.addEventListener('click', saveTask);

    // Ctrl+Enter in form
    const taskForm = document.getElementById('task-form');
    if (taskForm) {
      taskForm.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && e.ctrlKey) saveTask();
      });
    }

    // Sort toggle
    const sortToggle = document.getElementById('sort-toggle-btn');
    if (sortToggle) {
      sortToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        const dd = document.getElementById('sort-dropdown');
        if (dd) dd.classList.toggle('active');
      });
    }

    // Sort options
    document.querySelectorAll('.sort-option').forEach(opt => {
      opt.addEventListener('click', () => setSort(opt.dataset.sort));
    });

    // View toggle
    document.querySelectorAll('.view-toggle-btn').forEach(btn => {
      btn.addEventListener('click', () => setView(btn.dataset.view));
    });
  }

  // --- Helpers ---
  function getCategoryIcon(cat) {
    const icons = { Work: '💼', Personal: '🏠', Learning: '📚', Other: '📌' };
    return icons[cat] || '📌';
  }

  function getPriorityLabel(priority) {
    const labels = { high: 'Cao', medium: 'TB', low: 'Thấp' };
    return labels[priority] || priority;
  }

  function formatDeadline(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const now = new Date();
    const diff = date - now;
    const days = Math.floor(diff / 86400000);
    if (diff < 0) return '⚠️ Quá hạn!';
    if (days === 0) {
      const hours = Math.floor(diff / 3600000);
      if (hours <= 0) return '🔴 Sắp hết hạn!';
      return `⏰ Còn ${hours}h`;
    }
    if (days === 1) return 'Ngày mai';
    if (days < 7) return `${days} ngày nữa`;
    return date.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' });
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove('active');
  }

  return {
    init, renderAllTasks, openAddModal, editTask, saveTask, confirmDeleteTask,
    touchTask, toggleDropdown, setFilter, setSearch, setSort, setView,
    closeAllDropdowns, updateQuickStats,
  };
})();
