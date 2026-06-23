/* ============================================
   TaskMind — Storage Module
   localStorage wrapper with auto-save
   ============================================ */

const Storage = (() => {
  const KEYS = {
    TASKS: 'taskmind_tasks',
    ACTIVITY: 'taskmind_activity',
    SETTINGS: 'taskmind_settings',
    LAST_VISIT: 'taskmind_last_visit',
    STREAK: 'taskmind_streak',
  };

  const MAX_ACTIVITY_ITEMS = 50;

  // --- Tasks ---
  function loadTasks() {
    try {
      const data = localStorage.getItem(KEYS.TASKS);
      return data ? JSON.parse(data) : [];
    } catch (e) {
      console.error('Failed to load tasks:', e);
      return [];
    }
  }

  function saveTasks(tasks) {
    try {
      localStorage.setItem(KEYS.TASKS, JSON.stringify(tasks));
    } catch (e) {
      console.error('Failed to save tasks:', e);
    }
  }

  function getTask(id) {
    return loadTasks().find(t => t.id === id) || null;
  }

  function addTask(task) {
    const tasks = loadTasks();
    tasks.push(task);
    saveTasks(tasks);
    logActivity('created', task);
    return task;
  }

  function updateTask(id, updates) {
    const tasks = loadTasks();
    const idx = tasks.findIndex(t => t.id === id);
    if (idx === -1) return null;

    const oldTask = { ...tasks[idx] };
    tasks[idx] = { ...tasks[idx], ...updates, updatedAt: Date.now() };

    // Log status change
    if (updates.status && updates.status !== oldTask.status) {
      logActivity('moved', tasks[idx], `${formatStatus(oldTask.status)} → ${formatStatus(updates.status)}`);
      if (updates.status === 'done') {
        tasks[idx].completedAt = Date.now();
      }
    } else {
      logActivity('updated', tasks[idx]);
    }

    saveTasks(tasks);
    return tasks[idx];
  }

  function deleteTask(id) {
    const tasks = loadTasks();
    const task = tasks.find(t => t.id === id);
    if (task) {
      logActivity('deleted', task);
    }
    const filtered = tasks.filter(t => t.id !== id);
    saveTasks(filtered);
  }

  function moveTask(id, newStatus) {
    return updateTask(id, { status: newStatus });
  }

  // --- Activity Log ---
  function loadActivity() {
    try {
      const data = localStorage.getItem(KEYS.ACTIVITY);
      return data ? JSON.parse(data) : [];
    } catch (e) {
      return [];
    }
  }

  function logActivity(action, task, extra = '') {
    const activity = loadActivity();
    activity.unshift({
      id: generateId(),
      action,
      taskTitle: task.title,
      taskId: task.id,
      extra,
      timestamp: Date.now(),
    });
    // Keep only latest
    if (activity.length > MAX_ACTIVITY_ITEMS) {
      activity.length = MAX_ACTIVITY_ITEMS;
    }
    localStorage.setItem(KEYS.ACTIVITY, JSON.stringify(activity));
  }

  // --- Settings ---
  function loadSettings() {
    try {
      const data = localStorage.getItem(KEYS.SETTINGS);
      return data ? JSON.parse(data) : getDefaultSettings();
    } catch (e) {
      return getDefaultSettings();
    }
  }

  function saveSettings(settings) {
    localStorage.setItem(KEYS.SETTINGS, JSON.stringify(settings));
  }

  function getDefaultSettings() {
    return {
      forgottenDays: 2,
      idleMinutes: 30,
      notificationsEnabled: true,
      categories: ['Work', 'Personal', 'Learning', 'Other'],
    };
  }

  // --- Last Visit & Streak ---
  function getLastVisit() {
    return parseInt(localStorage.getItem(KEYS.LAST_VISIT) || '0');
  }

  function setLastVisit() {
    localStorage.setItem(KEYS.LAST_VISIT, Date.now().toString());
  }

  function getStreak() {
    try {
      const data = localStorage.getItem(KEYS.STREAK);
      return data ? JSON.parse(data) : { count: 0, lastDate: null };
    } catch (e) {
      return { count: 0, lastDate: null };
    }
  }

  function updateStreak() {
    const streak = getStreak();
    const today = new Date().toDateString();

    if (streak.lastDate === today) return streak;

    const yesterday = new Date(Date.now() - 86400000).toDateString();
    if (streak.lastDate === yesterday) {
      streak.count += 1;
    } else if (streak.lastDate !== today) {
      streak.count = 1;
    }
    streak.lastDate = today;
    localStorage.setItem(KEYS.STREAK, JSON.stringify(streak));
    return streak;
  }

  // --- Export / Import ---
  function exportData() {
    const data = {
      version: '1.0',
      exportedAt: new Date().toISOString(),
      tasks: loadTasks(),
      activity: loadActivity(),
      settings: loadSettings(),
      streak: getStreak(),
    };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `taskmind-backup-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
  }

  function importData(jsonString) {
    try {
      const data = JSON.parse(jsonString);
      if (!data.version || !data.tasks) {
        throw new Error('Invalid backup format');
      }
      saveTasks(data.tasks);
      if (data.activity) {
        localStorage.setItem(KEYS.ACTIVITY, JSON.stringify(data.activity));
      }
      if (data.settings) {
        saveSettings(data.settings);
      }
      if (data.streak) {
        localStorage.setItem(KEYS.STREAK, JSON.stringify(data.streak));
      }
      return { success: true, taskCount: data.tasks.length };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }

  // --- Helpers ---
  function generateId() {
    return crypto.randomUUID ? crypto.randomUUID() :
      'xxxx-xxxx-xxxx'.replace(/x/g, () => Math.floor(Math.random() * 16).toString(16));
  }

  function formatStatus(status) {
    const map = { todo: 'To Do', doing: 'Đang làm', done: 'Hoàn thành' };
    return map[status] || status;
  }

  // Public API
  return {
    loadTasks,
    saveTasks,
    getTask,
    addTask,
    updateTask,
    deleteTask,
    moveTask,
    loadActivity,
    logActivity,
    loadSettings,
    saveSettings,
    getLastVisit,
    setLastVisit,
    getStreak,
    updateStreak,
    exportData,
    importData,
    generateId,
  };
})();
