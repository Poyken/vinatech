/* ============================================
   TaskMind — Dashboard Logic
   Stats, charts, activity timeline
   ============================================ */

const Dashboard = (() => {

  function init() {
    refresh();
  }

  function refresh() {
    const tasks = Storage.loadTasks();
    const settings = Storage.loadSettings();
    const activity = Storage.loadActivity();

    renderStats(tasks, settings);
    renderCompletionRing(tasks);
    renderForgottenAlerts(tasks, settings);
    renderCategoryChart(tasks);
    renderStreak();
    renderActivityTimeline(activity);
  }

  // --- Stats Cards ---
  function renderStats(tasks, settings) {
    const now = Date.now();
    const total = tasks.length;
    const doing = tasks.filter(t => t.status === 'doing').length;
    const done = tasks.filter(t => t.status === 'done').length;

    const forgotten = tasks.filter(t =>
      t.status === 'doing' && (now - t.updatedAt) / 86400000 > settings.forgottenDays
    ).length;

    const overdue = tasks.filter(t =>
      t.status !== 'done' && t.deadline && new Date(t.deadline) < now
    ).length;

    animateValue('stat-total', total);
    animateValue('stat-doing', doing);
    animateValue('stat-done', done);
    animateValue('stat-forgotten', forgotten);
    animateValue('stat-overdue', overdue);
  }

  function animateValue(elementId, targetValue) {
    const el = document.getElementById(elementId);
    if (!el) return;

    const start = parseInt(el.textContent) || 0;
    if (start === targetValue) { el.textContent = targetValue; return; }

    const duration = 600;
    const startTime = performance.now();

    function update(currentTime) {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3); // easeOutCubic
      const current = Math.round(start + (targetValue - start) * eased);
      el.textContent = current;

      if (progress < 1) requestAnimationFrame(update);
    }

    requestAnimationFrame(update);
  }

  // --- Completion Ring ---
  function renderCompletionRing(tasks) {
    const total = tasks.length;
    const done = tasks.filter(t => t.status === 'done').length;
    const percentage = total > 0 ? Math.round((done / total) * 100) : 0;

    const ring = document.querySelector('.completion-ring');
    const fill = document.querySelector('.ring-fill');
    const valueEl = document.getElementById('completion-value');

    if (valueEl) valueEl.textContent = `${percentage}%`;

    if (fill) {
      // Circle circumference = 2 * π * r = 2 * 3.14159 * 70 ≈ 440
      const circumference = 440;
      const offset = circumference - (circumference * percentage / 100);
      fill.style.strokeDashoffset = offset;
    }

    if (ring) {
      ring.classList.add('animate');
    }
  }

  // --- Forgotten Alerts ---
  function renderForgottenAlerts(tasks, settings) {
    const container = document.getElementById('forgotten-alerts-list');
    if (!container) return;

    const forgotten = Reminder.getForgottenTasks();

    if (forgotten.length === 0) {
      container.innerHTML = `
        <div class="empty-state" style="padding: var(--space-xl);">
          <div class="empty-state-icon">✅</div>
          <div class="empty-state-text">Không có task nào bị quên! Tuyệt vời!</div>
        </div>
      `;
      return;
    }

    container.innerHTML = forgotten.map(task => {
      const days = Math.floor((Date.now() - task.updatedAt) / 86400000);
      return `
        <div class="forgotten-item">
          <div class="forgotten-item-icon">⚠️</div>
          <div class="forgotten-item-info">
            <div class="forgotten-item-title">${escapeHtml(task.title)}</div>
            <div class="forgotten-item-days">Quên ${days} ngày — ${task.category}</div>
          </div>
          <div class="forgotten-item-action">
            <button class="btn btn-sm btn-primary" onclick="Dashboard.resumeTask('${task.id}')">
              ▶ Quay lại
            </button>
          </div>
        </div>
      `;
    }).join('');
  }

  function resumeTask(id) {
    Storage.updateTask(id, {}); // Touch to reset updatedAt
    refresh();
    TaskBoard.renderAllTasks();
    App.showToast('Đã đánh dấu tiếp tục làm!', 'success');
  }

  // --- Category Chart ---
  function renderCategoryChart(tasks) {
    const container = document.getElementById('category-chart');
    if (!container) return;

    const activeTasks = tasks.filter(t => t.status !== 'done');
    if (activeTasks.length === 0) {
      container.innerHTML = `
        <div class="empty-state" style="padding: var(--space-lg);">
          <div class="empty-state-text">Chưa có task active</div>
        </div>
      `;
      return;
    }

    const categories = {};
    activeTasks.forEach(t => {
      categories[t.category] = (categories[t.category] || 0) + 1;
    });

    const total = activeTasks.length;
    const sorted = Object.entries(categories).sort((a, b) => b[1] - a[1]);

    container.innerHTML = sorted.map(([cat, count]) => {
      const percent = Math.round((count / total) * 100);
      const cssClass = cat.toLowerCase();
      const icons = { Work: '💼', Personal: '🏠', Learning: '📚', Other: '📌' };
      const icon = icons[cat] || '📌';
      return `
        <div class="category-bar">
          <div class="category-bar-header">
            <span class="category-bar-label">${icon} ${escapeHtml(cat)}</span>
            <span class="category-bar-value">${count} task (${percent}%)</span>
          </div>
          <div class="category-bar-track">
            <div class="category-bar-fill ${cssClass}" style="width: ${percent}%"></div>
          </div>
        </div>
      `;
    }).join('');
  }

  // --- Streak ---
  function renderStreak() {
    const streak = Storage.getStreak();
    const countEl = document.getElementById('streak-count');
    const fireEl = document.getElementById('streak-fire');

    if (countEl) countEl.textContent = streak.count;
    if (fireEl) {
      const fires = Math.min(streak.count, 7);
      fireEl.innerHTML = Array(fires).fill('<span>🔥</span>').join('');
    }
  }

  // --- Activity Timeline ---
  function renderActivityTimeline(activity) {
    const container = document.getElementById('activity-timeline');
    if (!container) return;

    const recent = activity.slice(0, 10);

    if (recent.length === 0) {
      container.innerHTML = `
        <div class="empty-state" style="padding: var(--space-xl);">
          <div class="empty-state-icon">📋</div>
          <div class="empty-state-text">Chưa có hoạt động nào</div>
        </div>
      `;
      return;
    }

    container.innerHTML = recent.map(item => {
      const dotClass = {
        created: 'activity-dot-created',
        moved: 'activity-dot-moved',
        completed: 'activity-dot-completed',
        deleted: 'activity-dot-deleted',
        updated: 'activity-dot-moved',
      }[item.action] || 'activity-dot-moved';

      const actionText = {
        created: 'Tạo mới',
        moved: 'Di chuyển',
        completed: 'Hoàn thành',
        deleted: 'Xóa',
        updated: 'Cập nhật',
      }[item.action] || item.action;

      const timeAgo = formatTimeAgo(item.timestamp);

      return `
        <div class="activity-item">
          <div class="activity-dot ${dotClass}"></div>
          <div class="activity-content">
            <div class="activity-text">
              ${actionText} <strong>${escapeHtml(item.taskTitle)}</strong>
              ${item.extra ? `<span style="color: var(--text-tertiary);">${escapeHtml(item.extra)}</span>` : ''}
            </div>
            <div class="activity-time">${timeAgo}</div>
          </div>
        </div>
      `;
    }).join('');
  }

  // --- Helpers ---
  function formatTimeAgo(timestamp) {
    const diff = Date.now() - timestamp;
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return 'Vừa xong';
    if (minutes < 60) return `${minutes} phút trước`;
    if (hours < 24) return `${hours} giờ trước`;
    if (days < 7) return `${days} ngày trước`;

    return new Date(timestamp).toLocaleDateString('vi-VN');
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  // Public API
  return {
    init,
    refresh,
    resumeTask,
  };
})();
