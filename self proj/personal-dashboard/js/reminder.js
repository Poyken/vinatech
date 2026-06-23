/* ============================================
   TaskMind — Reminder Engine (Polished)
   Time-aware greeting, smarter notifications
   ============================================ */

const Reminder = (() => {
  let checkInterval = null;
  let idleTimer = null;
  let lastInteraction = Date.now();
  const REMINDED_MAP = new Map();
  const ANTI_SPAM_MS = 4 * 60 * 60 * 1000; // 4 hours

  // --- Initialize ---
  function init() {
    requestNotificationPermission();
    startCheckLoop();
    setupIdleDetection();
    showMorningBriefing();
  }

  // --- Permission ---
  function requestNotificationPermission() {
    if (!('Notification' in window)) return;
    if (Notification.permission === 'default') {
      // Delay slightly to not annoy user immediately
      setTimeout(() => Notification.requestPermission(), 3000);
    }
  }

  function canNotify() {
    return 'Notification' in window && Notification.permission === 'granted';
  }

  // --- Send Notification ---
  function sendNotification(title, body, icon = '🧠') {
    if (typeof App !== 'undefined' && App.showToast) {
      App.showToast(body, 'warning');
    }

    if (canNotify()) {
      try {
        const notif = new Notification(title, {
          body,
          icon: `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><text y=".9em" font-size="90">${icon}</text></svg>`,
          tag: `taskmind-${Date.now()}`,
          requireInteraction: false,
        });

        notif.onclick = () => {
          window.focus();
          notif.close();
        };

        setTimeout(() => notif.close(), 8000);
      } catch (e) {
        console.warn('Notification failed:', e);
      }
    }
  }

  // --- Anti-spam ---
  function shouldRemind(key) {
    const last = REMINDED_MAP.get(key);
    if (!last) return true;
    return (Date.now() - last) > ANTI_SPAM_MS;
  }

  function markReminded(key) {
    REMINDED_MAP.set(key, Date.now());
  }

  // --- Check Loop ---
  function startCheckLoop() {
    checkTasks();
    checkInterval = setInterval(checkTasks, 60000);
  }

  function checkTasks() {
    const tasks = Storage.loadTasks();
    const settings = Storage.loadSettings();
    const now = Date.now();
    let alertCount = 0;

    tasks.forEach(task => {
      if (task.status === 'done') return;

      // 1. Deadline approaching (< 1 hour)
      if (task.deadline) {
        const deadlineTime = new Date(task.deadline).getTime();
        const timeLeft = deadlineTime - now;

        if (timeLeft > 0 && timeLeft < 3600000 && shouldRemind(task.id + '_deadline')) {
          sendNotification(
            '⏰ Deadline sắp tới!',
            `"${task.title}" — còn ${Math.round(timeLeft / 60000)} phút`,
            '⏰'
          );
          markReminded(task.id + '_deadline');
        }

        if (timeLeft < 0) alertCount++;
      }

      // 2. Forgotten task
      if (task.status === 'doing') {
        const daysSince = (now - task.updatedAt) / 86400000;
        if (daysSince > settings.forgottenDays) {
          alertCount++;
          if (shouldRemind(task.id + '_forgotten')) {
            sendNotification(
              '⚠️ Task bị quên!',
              `"${task.title}" — ${Math.floor(daysSince)} ngày không động tới!`,
              '⚠️'
            );
            markReminded(task.id + '_forgotten');
          }
        }
      }
    });

    updateBadge(alertCount);
  }

  function updateBadge(count) {
    const dot = document.getElementById('nav-notification-dot');
    const badge = document.getElementById('nav-notification-badge');

    if (dot) dot.style.display = count > 0 ? 'block' : 'none';
    if (badge) {
      badge.textContent = count;
      badge.style.display = count > 0 ? 'inline-flex' : 'none';
    }
  }

  // --- Idle Detection ---
  function setupIdleDetection() {
    const events = ['mousedown', 'mousemove', 'keydown', 'scroll', 'touchstart', 'click'];
    events.forEach(event => {
      document.addEventListener(event, resetIdle, { passive: true });
    });
    resetIdle();
  }

  function resetIdle() {
    lastInteraction = Date.now();
    if (idleTimer) clearTimeout(idleTimer);

    const settings = Storage.loadSettings();
    const idleMs = (settings.idleMinutes || 30) * 60 * 1000;

    idleTimer = setTimeout(onIdle, idleMs);
  }

  function onIdle() {
    const tasks = Storage.loadTasks();
    const pendingCount = tasks.filter(t => t.status !== 'done').length;

    if (pendingCount > 0) {
      sendNotification(
        '💤 Đừng quên việc!',
        `Bạn có ${pendingCount} task đang chờ xử lý. Quay lại làm nào!`,
        '💤'
      );
    }

    const settings = Storage.loadSettings();
    const idleMs = (settings.idleMinutes || 30) * 60 * 1000;
    idleTimer = setTimeout(onIdle, idleMs);
  }

  // --- Morning Briefing ---
  function showMorningBriefing() {
    const lastVisit = Storage.getLastVisit();
    const now = Date.now();
    const hoursSince = (now - lastVisit) / 3600000;

    if (lastVisit === 0 || hoursSince > 4) {
      const tasks = Storage.loadTasks();
      if (tasks.length === 0) {
        Storage.setLastVisit();
        return;
      }

      const settings = Storage.loadSettings();
      const stats = calculateBriefingStats(tasks, settings);

      setTimeout(() => {
        renderBriefingModal(stats);
      }, 1000);
    }

    Storage.setLastVisit();
  }

  function getTimeGreeting() {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return { text: '🌅 Chào buổi sáng!', sub: 'Bắt đầu ngày mới hiệu quả nào!' };
    if (hour >= 12 && hour < 14) return { text: '☀️ Chào buổi trưa!', sub: 'Nghỉ ngơi một chút rồi tiếp tục nhé!' };
    if (hour >= 14 && hour < 18) return { text: '🌤️ Chào buổi chiều!', sub: 'Cố gắng hoàn thành task hôm nay!' };
    if (hour >= 18 && hour < 22) return { text: '🌆 Chào buổi tối!', sub: 'Review lại công việc trong ngày nào!' };
    return { text: '🌙 Khuya rồi!', sub: 'Đừng thức quá khuya nhé!' };
  }

  function calculateBriefingStats(tasks, settings) {
    const now = Date.now();
    const doing = tasks.filter(t => t.status === 'doing');
    const todo = tasks.filter(t => t.status === 'todo');
    const done = tasks.filter(t => t.status === 'done');

    const forgotten = doing.filter(t => (now - t.updatedAt) / 86400000 > settings.forgottenDays);

    const overdue = tasks.filter(t => {
      if (t.status === 'done' || !t.deadline) return false;
      return new Date(t.deadline) < now;
    });

    const dueSoon = tasks.filter(t => {
      if (t.status === 'done' || !t.deadline) return false;
      const timeLeft = new Date(t.deadline) - now;
      return timeLeft > 0 && timeLeft < 86400000;
    });

    return {
      total: tasks.length,
      todoCount: todo.length,
      doingCount: doing.length,
      doneCount: done.length,
      forgottenTasks: forgotten,
      overdueTasks: overdue,
      dueSoonTasks: dueSoon,
    };
  }

  function renderBriefingModal(stats) {
    const modal = document.getElementById('briefing-modal');
    if (!modal) return;

    // Time-based greeting
    const greeting = getTimeGreeting();
    const greetingEl = document.getElementById('briefing-greeting');
    const greetingSubEl = document.getElementById('briefing-greeting-sub');
    if (greetingEl) greetingEl.textContent = greeting.text;
    if (greetingSubEl) greetingSubEl.textContent = greeting.sub;

    const el = (id) => document.getElementById(id);
    if (el('briefing-todo')) el('briefing-todo').textContent = stats.todoCount;
    if (el('briefing-doing')) el('briefing-doing').textContent = stats.doingCount;
    if (el('briefing-done')) el('briefing-done').textContent = stats.doneCount;
    if (el('briefing-forgotten-count')) el('briefing-forgotten-count').textContent = stats.forgottenTasks.length;

    // Forgotten list
    const forgottenContainer = el('briefing-forgotten-list-container');
    if (forgottenContainer) {
      if (stats.forgottenTasks.length > 0) {
        forgottenContainer.style.display = 'block';
        const list = forgottenContainer.querySelector('.briefing-forgotten-list');
        if (list) {
          list.innerHTML = stats.forgottenTasks.map(t => {
            const days = Math.floor((Date.now() - t.updatedAt) / 86400000);
            return `<div class="briefing-forgotten-item">• <strong>${t.title}</strong> <span style="color: var(--color-danger);">(${days} ngày không động)</span></div>`;
          }).join('');
        }
      } else {
        forgottenContainer.style.display = 'none';
      }
    }

    // Due soon
    const dueSoonContainer = el('briefing-due-soon');
    if (dueSoonContainer) {
      if (stats.dueSoonTasks.length > 0) {
        dueSoonContainer.style.display = 'block';
        const list = dueSoonContainer.querySelector('.briefing-forgotten-list');
        if (list) {
          list.innerHTML = stats.dueSoonTasks.map(t => {
            const hoursLeft = Math.round((new Date(t.deadline) - Date.now()) / 3600000);
            return `<div class="briefing-forgotten-item">• <strong>${t.title}</strong> <span style="color: var(--color-warning);">(còn ${hoursLeft}h)</span></div>`;
          }).join('');
        }
      } else {
        dueSoonContainer.style.display = 'none';
      }
    }

    modal.classList.add('active');
  }

  // --- Dashboard helpers ---
  function getForgottenTasks() {
    const tasks = Storage.loadTasks();
    const settings = Storage.loadSettings();
    const now = Date.now();
    return tasks.filter(t => {
      if (t.status !== 'doing') return false;
      return (now - t.updatedAt) / 86400000 > settings.forgottenDays;
    }).sort((a, b) => a.updatedAt - b.updatedAt);
  }

  function getOverdueTasks() {
    const tasks = Storage.loadTasks();
    const now = Date.now();
    return tasks.filter(t => {
      if (t.status === 'done' || !t.deadline) return false;
      return new Date(t.deadline) < now;
    });
  }

  return {
    init,
    checkTasks,
    getForgottenTasks,
    getOverdueTasks,
    sendNotification,
    showMorningBriefing,
    canNotify,
    requestNotificationPermission,
  };
})();
