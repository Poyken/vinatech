/**
 * VINATECH FACE ID & ACCESS CONTROL WEB APPLICATION
 * Core Client Controller & Interactive Blueprint Engine
 */

// Multi-Language Translation Dictionary
const I18N = {
  vi: {
    nav_dashboard: "Bảng Điều Khiển",
    nav_map: "Mặt Bằng & Vị Trí",
    nav_attendance: "Báo Cáo Chấm Công",
    nav_devices: "Danh Mục Thiết Bị",
    nav_personnel: "Nhân Sự & Phân Quyền",
    nav_sql: "Tra Cứu Database",
    nav_manual: "Sổ Tay Vận Hành (SOP)",
    btn_refresh: "Làm mới",
    stat_total_scans: "Tổng Lượt Sự Kiện",
    stat_realtime_synced: "Đồng bộ thời gian thực",
    stat_face_rate: "Tỷ Lệ Quẹt Face ID",
    stat_primary_method: "Phương thức chính",
    stat_total_devices: "Tổng Số Thiết Bị",
    stat_active_shift: "Ca Làm Việc Chuẩn",
    title_live_events: "Nhật Ký Quẹt Face ID & Cửa Thời Gian Thực",
    title_floorplans: "Mặt Bằng & Bản Đồ Phân Bổ Thiết Bị Face ID",
    title_attendance: "Báo Cáo Chấm Công Hàng Ngày (First In / Last Out)",
    btn_export_csv: "Xuất File CSV",
    title_devices: "Danh Mục Toàn Bộ 22 Thiết Bị Face ID & Cửa",
    title_personnel: "Danh Bạ Nhân Sự & Phân Quyền Mở Cửa",
    title_manual: "Sổ Tay Vận Hành & Đào Tạo Chuẩn Hóa (Training SOP)"
  },
  en: {
    nav_dashboard: "Dashboard",
    nav_map: "Floor Plans & Devices",
    nav_attendance: "Attendance Reports",
    nav_devices: "Device Inventory",
    nav_personnel: "Personnel & Access",
    nav_sql: "Database Query",
    nav_manual: "Operations Manual (SOP)",
    btn_refresh: "Refresh",
    stat_total_scans: "Total Event Scans",
    stat_realtime_synced: "Real-time Synced",
    stat_face_rate: "Face ID Rate",
    stat_primary_method: "Primary Method",
    stat_total_devices: "Total Devices",
    stat_active_shift: "Standard Work Shift",
    title_live_events: "Real-Time Face ID & Door Access Log",
    title_floorplans: "Interactive Floor Plans & Device Placement Map",
    title_attendance: "Daily Attendance Summary (First In / Last Out)",
    btn_export_csv: "Export CSV",
    title_devices: "Complete Inventory of 22 Face ID & Door Devices",
    title_personnel: "Personnel Directory & Access Privileges",
    title_manual: "Standard Operating Procedures & Training (SOP)"
  },
  ko: {
    nav_dashboard: "대시보드",
    nav_map: "도면 및 기기 위치",
    nav_attendance: "근태 집계 보고서",
    nav_devices: "전체 장비 목록",
    nav_personnel: "인사 및 출입 권한",
    nav_sql: "데이터베이스 조회",
    nav_manual: "운영 매뉴얼 (SOP)",
    btn_refresh: "새로고침",
    stat_total_scans: "총 출입/근태 로그",
    stat_realtime_synced: "실시간 동기화 완료",
    stat_face_rate: "Face ID 인증 비율",
    stat_primary_method: "주요 인증 방식",
    stat_total_devices: "총 설치 기기",
    stat_active_shift: "표준 근무조",
    title_live_events: "실시간 Face ID 및 출입문 로그",
    title_floorplans: "도면 기반 대화형 기기 배치도",
    title_attendance: "일일 근태 집계 (첫 출근 / 최종 퇴근)",
    btn_export_csv: "CSV 내보내기",
    title_devices: "22개 전체 Face ID 및 도어 기기 제원",
    title_personnel: "임직원 명부 및 출입 권한",
    title_manual: "표준 운영 지침 및 교육 매뉴얼 (SOP)"
  }
};

let appData = {
  systemInfo: {},
  devices: [],
  employees: [],
  sopSteps: []
};

let currentLang = 'vi';
let liveEvents = [];

// Initialize Application
document.addEventListener('DOMContentLoaded', async () => {
  setupTheme();
  setupNavigation();
  setupLanguageSwitcher();
  setupModal();
  setupSqlStudio();
  
  await loadStaticData();
  renderAllViews();
  await refreshLiveStatus();

  // Polling loop every 8 seconds
  setInterval(refreshLiveStatus, 8000);
});

// Load static json data
async function loadStaticData() {
  try {
    const res = await fetch('data.json');
    if (res.ok) {
      appData = await res.json();
    }
  } catch (err) {
    console.error("Failed to load data.json:", err);
  }
}

// Setup Theme (Dark / Light)
function setupTheme() {
  const btn = document.getElementById('theme-toggle-btn');
  const saved = localStorage.getItem('vnt_theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);

  btn.addEventListener('click', () => {
    const curr = document.documentElement.getAttribute('data-theme');
    const next = curr === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('vnt_theme', next);
  });
}

// Setup Navigation
function setupNavigation() {
  const items = document.querySelectorAll('.nav-item');
  items.forEach(item => {
    item.addEventListener('click', () => {
      items.forEach(i => i.classList.remove('active'));
      item.classList.add('active');

      const viewId = item.getAttribute('data-view');
      showView(viewId);
    });
  });

  document.getElementById('btn-refresh').addEventListener('click', refreshLiveStatus);
}

function showView(viewId) {
  document.querySelectorAll('.view-section').forEach(sec => {
    sec.classList.remove('active');
  });
  
  const target = document.getElementById(`view-${viewId}`);
  if (target) {
    target.classList.add('active');
  }

  // Update Breadcrumbs
  const navItem = document.querySelector(`.nav-item[data-view="${viewId}"]`);
  if (navItem) {
    const label = navItem.querySelector('span:nth-child(2)').textContent;
    document.getElementById('current-view-name').textContent = label;
  }

  // Specific view hooks
  if (viewId === 'floorplans') {
    renderFloorMap('1F');
  } else if (viewId === 'attendance') {
    loadAttendanceData();
  }
}

// Setup Language Switcher
function setupLanguageSwitcher() {
  const select = document.getElementById('lang-select');
  select.addEventListener('change', (e) => {
    currentLang = e.target.value;
    updateLanguage(currentLang);
  });
}

function updateLanguage(lang) {
  const dict = I18N[lang] || I18N.vi;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (dict[key]) {
      el.textContent = dict[key];
    }
  });
}

// Refresh Live Status from Backend
async function refreshLiveStatus() {
  try {
    const [statusRes, eventsRes, statsRes] = await Promise.all([
      fetch('/api/status').catch(() => null),
      fetch('/api/events?limit=100').catch(() => null),
      fetch('/api/stats').catch(() => null)
    ]);

    if (statusRes && statusRes.ok) {
      const statusData = await statusRes.json();
      const dot = document.querySelector('.status-dot');
      const text = document.getElementById('db-status-text');
      if (statusData.status === 'connected') {
        dot.style.background = 'var(--accent-emerald)';
        dot.style.boxShadow = '0 0 10px var(--accent-emerald)';
        text.textContent = `HCP_DATA: Đã kết nối (${statusData.server}) — ${statusData.totalEvents} Sự kiện`;
      }
    }

    if (eventsRes && eventsRes.ok) {
      liveEvents = await eventsRes.json();
      renderDashboardEvents(liveEvents);
      document.getElementById('live-event-count').textContent = `Hiển thị ${liveEvents.length} bản ghi gần nhất`;
    }

    if (statsRes && statsRes.ok) {
      const stats = await statsRes.json();
      document.getElementById('stat-total-scans').textContent = stats.totalEvents + "+";
      document.getElementById('stat-face-rate').textContent = stats.faceIdPercentage + "%";
    }
  } catch (e) {
    console.warn("Live status update error:", e);
  }
}

// Render All Initial Views
function renderAllViews() {
  renderDevicesTable();
  renderPersonnelTable();
  renderSopCards();
  renderFloorTabs();
  renderFloorMap('1F');
  setupDashboardFilters();
  setupAttendanceFilters();
}

// Render Dashboard Events Table
function renderDashboardEvents(events) {
  const tbody = document.getElementById('dashboard-events-tbody');
  tbody.innerHTML = '';

  if (!events || events.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 24px;">Chưa có dữ liệu sự kiện</td></tr>`;
    return;
  }

  events.forEach(e => {
    const tr = document.createElement('tr');
    
    // Auth Badge
    let badgeClass = 'badge-face';
    let authLabel = 'Face ID';
    const authType = e.AuthenticationType || '';
    if (authType.includes('Finger')) {
      badgeClass = 'badge-finger';
      authLabel = 'Vân Tay';
    } else if (authType.includes('Card')) {
      badgeClass = 'badge-card';
      authLabel = 'Thẻ Từ';
    }

    tr.innerHTML = `
      <td><span style="font-family: var(--font-mono); font-weight: 700; color: var(--accent-primary);">${e.EmployeeID || '—'}</span></td>
      <td><strong>${e.PersonName || 'Chưa định danh'}</strong></td>
      <td><span class="badge" style="background: rgba(255,255,255,0.06);">${e.Department || 'Chung'}</span></td>
      <td><span style="font-family: var(--font-mono); color: var(--text-secondary);">${e.AccessDate || ''} ${e.AccessTime || ''}</span></td>
      <td><strong>${e.DeviceName || 'Device'}</strong> <span style="font-size: 11px; color: var(--text-muted);">(${e.ResourceName || ''})</span></td>
      <td><span class="badge ${badgeClass}">${authLabel}</span></td>
      <td><span class="badge badge-success">Thành công</span></td>
    `;
    tbody.appendChild(tr);
  });
}

function setupDashboardFilters() {
  const search = document.getElementById('dashboard-search');
  const devSelect = document.getElementById('filter-device');

  const filterFn = () => {
    const q = search.value.toLowerCase();
    const dev = devSelect.value;
    const filtered = liveEvents.filter(e => {
      const matchQ = (e.PersonName || '').toLowerCase().includes(q) || (e.EmployeeID || '').toLowerCase().includes(q);
      const matchDev = !dev || (e.DeviceName || '') === dev;
      return matchQ && matchDev;
    });
    renderDashboardEvents(filtered);
  };

  search.addEventListener('input', filterFn);
  devSelect.addEventListener('change', filterFn);
}

// Floor Plans Map Rendering
function renderFloorTabs() {
  const tabs = document.querySelectorAll('.floor-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      renderFloorMap(tab.getAttribute('data-floor'));
    });
  });
}

function renderFloorMap(floor) {
  const container = document.getElementById('floor-blueprint-wrap');
  const devicesOnFloor = appData.devices.filter(d => d.floor === floor);

  let floorBgBoxes = '';
  
  if (floor === '1F') {
    floorBgBoxes = `
      <!-- Tầng 1 Rooms -->
      <rect x="5%" y="15%" width="20%" height="70%" class="room-box" rx="6"/>
      <text x="15%" y="50%" class="room-label">Kho 1 (104) / Logistic Dock (105)</text>

      <rect x="28%" y="15%" width="25%" height="32%" class="room-box" rx="6"/>
      <text x="40.5%" y="31%" class="room-label">Locker Nữ (136) / QC Room</text>

      <rect x="28%" y="52%" width="25%" height="33%" class="room-box" rx="6"/>
      <text x="40.5%" y="68%" class="room-label">Căn Tin & P. Nghỉ Ca (115A)</text>

      <rect x="56%" y="15%" width="18%" height="70%" class="room-box" rx="6"/>
      <text x="65%" y="50%" class="room-label">P. Điều Khiển (128) / Mixer 1</text>

      <rect x="76%" y="15%" width="20%" height="70%" class="room-box" rx="6"/>
      <text x="86%" y="50%" class="room-label">Sảnh Chính & Showroom (101)</text>
    `;
  } else if (floor === '1.5F') {
    floorBgBoxes = `
      <rect x="25%" y="20%" width="50%" height="60%" class="room-box" rx="8"/>
      <text x="50%" y="50%" class="room-label">Khối Văn Phòng 1.5F (P. 201 & P. Giám Đốc 202)</text>
    `;
  } else if (floor === '2F') {
    floorBgBoxes = `
      <rect x="15%" y="20%" width="30%" height="60%" class="room-box" rx="8"/>
      <text x="30%" y="50%" class="room-label">P. IT & Server Room (304) [Rack Main 42U]</text>

      <rect x="55%" y="20%" width="35%" height="60%" class="room-box" rx="8"/>
      <text x="72.5%" y="50%" class="room-label">Văn Phòng Tầng 2 (302: HR, Kế toán, Mua hàng)</text>
    `;
  } else if (floor === 'PARKING') {
    floorBgBoxes = `
      <rect x="10%" y="15%" width="80%" height="32%" class="room-box" rx="8" style="stroke: #f59e0b;"/>
      <text x="50%" y="31%" class="room-label">5 Làn Flap Barrier CHIỀU VÀO (AC-10 -> AC-14)</text>

      <rect x="10%" y="53%" width="80%" height="32%" class="room-box" rx="8" style="stroke: #10b981;"/>
      <text x="50%" y="69%" class="room-label">5 Làn Flap Barrier CHIỀU RA (AC-15 -> AC-19)</text>
    `;
  }

  // Generate Pins
  let pinsSvg = '';
  devicesOnFloor.forEach(d => {
    const isAc = d.type === 'AC';
    const isBarrier = d.type === 'BARRIER';
    let pinClass = isAc ? 'pin-ac' : (isBarrier ? 'pin-barrier' : 'pin-ta');

    pinsSvg += `
      <g class="device-pin" onclick="openDeviceModal('${d.id}')" transform="translate(${d.x * 10}, ${d.y * 4.4})">
        <circle cx="0" cy="0" r="14" class="pin-pulse" fill="${isAc ? '#6366f1' : (isBarrier ? '#f59e0b' : '#06b6d4')}"></circle>
        <circle cx="0" cy="0" r="12" class="pin-circle ${pinClass}"></circle>
        <text x="0" y="4" text-anchor="middle" font-size="10" font-weight="800" fill="#fff">${d.code.replace('AC-', 'A').replace('TA-', 'T')}</text>
        <title>${d.code}: ${d.name} (${d.typeLabel})</title>
      </g>
    `;
  });

  container.innerHTML = `
    <svg class="blueprint-svg" viewBox="0 0 1000 440" xmlns="http://www.w3.org/2000/svg">
      <!-- Grid Lines Background -->
      <defs>
        <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
          <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(255,255,255,0.03)" stroke-width="1"/>
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#grid)" />
      ${floorBgBoxes}
      ${pinsSvg}
    </svg>
  `;
}

// Modal inspection
function setupModal() {
  const modal = document.getElementById('device-modal');
  const closeBtn = document.getElementById('modal-close-btn');

  closeBtn.addEventListener('click', () => modal.classList.remove('active'));
  modal.addEventListener('click', (e) => {
    if (e.target === modal) modal.classList.remove('active');
  });
}

window.openDeviceModal = function(devId) {
  const dev = appData.devices.find(d => d.id === devId);
  if (!dev) return;

  document.getElementById('modal-icon').textContent = dev.icon || '🚪';
  document.getElementById('modal-device-name').textContent = dev.name;
  document.getElementById('modal-device-code').textContent = `Mã TB: ${dev.code} | ${dev.typeLabel}`;

  const body = document.getElementById('modal-body');
  body.innerHTML = `
    <div style="display: grid; grid-template-columns: 140px 1fr; gap: 10px; background: rgba(0,0,0,0.2); padding: 14px; border-radius: var(--radius-sm);">
      <span style="color: var(--text-muted);">Vị trí lắp đặt:</span>
      <strong>${dev.floorName} — ${dev.room}</strong>

      <span style="color: var(--text-muted);">Chức năng chính:</span>
      <strong>${dev.typeLabel}</strong>

      <span style="color: var(--text-muted);">Cơ cấu khóa/cổng:</span>
      <span style="color: var(--accent-cyan); font-weight: 700;">${dev.lockType}</span>

      <span style="color: var(--text-muted);">Phụ kiện an toàn:</span>
      <span>${(dev.accessories || []).join(' • ')}</span>

      <span style="color: var(--text-muted);">Tủ RACK quản lý:</span>
      <span>${dev.controller}</span>

      <span style="color: var(--text-muted);">Số Serial / IP:</span>
      <span style="font-family: var(--font-mono);">${dev.serialNo} (${dev.ipAddress})</span>
    </div>
    <div style="display: flex; gap: 10px; margin-top: 6px;">
      <span class="badge badge-success">● Trạng Thái: Trực Tuyến (Online)</span>
      <span class="badge badge-face">Face ID Ready</span>
    </div>
  `;

  document.getElementById('device-modal').classList.add('active');
};

// Render Devices Table View
function renderDevicesTable() {
  const tbody = document.getElementById('devices-tbody');
  const searchInput = document.getElementById('device-search');
  const filterType = document.getElementById('device-type-filter');

  const render = () => {
    tbody.innerHTML = '';
    const q = searchInput.value.toLowerCase();
    const type = filterType.value;

    const filtered = appData.devices.filter(d => {
      const matchQ = d.name.toLowerCase().includes(q) || d.code.toLowerCase().includes(q) || d.room.toLowerCase().includes(q);
      const matchType = !type || d.type === type;
      return matchQ && matchType;
    });

    filtered.forEach(d => {
      const tr = document.createElement('tr');
      tr.style.cursor = 'pointer';
      tr.onclick = () => window.openDeviceModal(d.id);

      tr.innerHTML = `
        <td><strong style="color: var(--accent-primary); font-family: var(--font-mono);">${d.code}</strong></td>
        <td><strong>${d.name}</strong><br><span style="font-size: 11px; color: var(--text-muted);">${d.room}</span></td>
        <td><span class="badge" style="background: rgba(255,255,255,0.06);">${d.floor}</span></td>
        <td><span class="badge ${d.type === 'AC' ? 'badge-face' : (d.type === 'BARRIER' ? 'badge-card' : 'badge-finger')}">${d.typeLabel}</span></td>
        <td>${d.lockType}</td>
        <td style="font-size: 11px; color: var(--text-secondary);">${(d.accessories || []).join(', ')}</td>
        <td><span style="font-family: var(--font-mono); font-size: 11px;">${d.controller}</span></td>
        <td><span style="font-family: var(--font-mono); color: var(--text-muted);">${d.serialNo}</span></td>
      `;
      tbody.appendChild(tr);
    });
  };

  searchInput.addEventListener('input', render);
  filterType.addEventListener('change', render);
  render();
}

// Render Personnel Table View
function renderPersonnelTable() {
  const tbody = document.getElementById('personnel-tbody');
  const search = document.getElementById('emp-search');

  const render = () => {
    tbody.innerHTML = '';
    const q = search.value.toLowerCase();
    const filtered = appData.employees.filter(e => e.name.toLowerCase().includes(q) || e.id.includes(q) || e.dept.toLowerCase().includes(q));

    filtered.forEach(e => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><span style="font-family: var(--font-mono); font-weight: 700; color: var(--accent-primary);">${e.id}</span></td>
        <td><strong>${e.name}</strong></td>
        <td><span class="badge" style="background: rgba(99,102,241,0.15);">${e.dept}</span></td>
        <td>${e.role}</td>
        <td>${e.face ? '<span class="badge badge-success">✓ Đã Đăng Ký</span>' : '<span class="badge badge-warn">Chưa Đăng Ký</span>'}</td>
        <td><span style="font-family: var(--font-mono); font-size: 12px; color: var(--accent-cyan);">${e.access}</span></td>
        <td><span class="badge" style="background: rgba(16,185,129,0.15); color: var(--accent-emerald);">${e.attGroup}</span></td>
      `;
      tbody.appendChild(tr);
    });
  };

  search.addEventListener('input', render);
  render();
}

// Attendance View
async function loadAttendanceData() {
  const dateInput = document.getElementById('att-date-picker');
  const deptSelect = document.getElementById('att-dept-filter');
  const tbody = document.getElementById('attendance-tbody');

  if (!dateInput.value) {
    dateInput.value = new Date().toISOString().slice(0, 10);
  }

  tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-muted); padding: 24px;">Đang tải dữ liệu chấm công...</td></tr>`;

  try {
    const res = await fetch(`/api/attendance?date=${dateInput.value}`);
    if (res.ok) {
      const list = await res.json();
      renderAttendanceTable(list);
    }
  } catch (e) {
    console.warn("Attendance load error:", e);
  }
}

function renderAttendanceTable(list) {
  const tbody = document.getElementById('attendance-tbody');
  const deptFilter = document.getElementById('att-dept-filter').value;
  tbody.innerHTML = '';

  const filtered = list.filter(item => !deptFilter || item.department === deptFilter);

  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-muted); padding: 24px;">Không có dữ liệu chấm công cho ngày đã chọn</td></tr>`;
    return;
  }

  filtered.forEach(item => {
    const tr = document.createElement('tr');
    let statusBadge = '<span class="badge badge-success">Đúng Giờ</span>';
    if (item.status === 'Late Arrival') {
      statusBadge = '<span class="badge badge-warn">Đi Muộn</span>';
    } else if (item.status === 'Early Departure') {
      statusBadge = '<span class="badge badge-card">Về Sớm</span>';
    }

    tr.innerHTML = `
      <td><span style="font-family: var(--font-mono); font-weight: 700; color: var(--accent-primary);">${item.employeeId}</span></td>
      <td><strong>${item.personName}</strong></td>
      <td><span class="badge" style="background: rgba(255,255,255,0.06);">${item.department || '—'}</span></td>
      <td><span style="font-family: var(--font-mono);">${item.date}</span></td>
      <td><strong style="color: var(--accent-emerald); font-family: var(--font-mono);">${item.firstCheckIn}</strong></td>
      <td><span style="font-size: 11px; color: var(--text-muted);">${item.checkInDevice || '—'}</span></td>
      <td><strong style="color: var(--accent-cyan); font-family: var(--font-mono);">${item.lastCheckOut}</strong></td>
      <td><span style="font-size: 11px; color: var(--text-muted);">${item.checkOutDevice || '—'}</span></td>
      <td><span style="font-weight: 700; font-family: var(--font-mono);">${item.totalScans}</span></td>
      <td>${statusBadge}</td>
    `;
    tbody.appendChild(tr);
  });
}

function setupAttendanceFilters() {
  document.getElementById('att-date-picker').addEventListener('change', loadAttendanceData);
  document.getElementById('att-dept-filter').addEventListener('change', loadAttendanceData);
  document.getElementById('btn-export-attendance').addEventListener('click', () => {
    window.location.href = `/api/attendance?date=${document.getElementById('att-date-picker').value}`;
  });
}

// Render SOP Training Manual Cards
function renderSopCards() {
  const container = document.getElementById('sop-cards-container');
  container.innerHTML = '';

  appData.sopSteps.forEach(s => {
    const card = document.createElement('div');
    card.className = 'sop-card';
    card.innerHTML = `
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <div class="sop-step-badge">${s.step}</div>
          <span style="font-size: 20px;">${s.icon}</span>
        </div>
        <span class="badge" style="background: rgba(99,102,241,0.15); color: var(--accent-primary); font-size: 10px;">${s.slides}</span>
      </div>
      <div class="sop-title">${s.title}</div>
      <div class="sop-desc">${s.desc}</div>
    `;
    container.appendChild(card);
  });
}

// SQL Studio Logic
function setupSqlStudio() {
  document.querySelectorAll('.quick-sql-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.getElementById('sql-input').value = btn.getAttribute('data-sql');
      runCustomSql();
    });
  });

  document.getElementById('btn-run-sql').addEventListener('click', runCustomSql);
}

async function runCustomSql() {
  const sql = document.getElementById('sql-input').value.trim();
  const thead = document.getElementById('sql-results-thead');
  const tbody = document.getElementById('sql-results-tbody');

  thead.innerHTML = '';
  tbody.innerHTML = `<tr><td style="text-align: center; color: var(--text-muted); padding: 24px;">Đang truy vấn CSDL HCP_DATA...</td></tr>`;

  try {
    // For default query, fetch from api events
    const res = await fetch('/api/events?limit=50');
    if (res.ok) {
      const data = await res.json();
      if (data.length === 0) {
        tbody.innerHTML = `<tr><td style="text-align: center; color: var(--text-muted); padding: 24px;">0 kết quả</td></tr>`;
        return;
      }

      // Build Headers
      const cols = Object.keys(data[0]);
      let trHead = '<tr>';
      cols.forEach(c => trHead += `<th>${c}</th>`);
      trHead += '</tr>';
      thead.innerHTML = trHead;

      // Build Rows
      tbody.innerHTML = '';
      data.forEach(row => {
        let tr = '<tr>';
        cols.forEach(c => tr += `<td>${row[c] || ''}</td>`);
        tr += '</tr>';
        tbody.innerHTML += tr;
      });
    }
  } catch (e) {
    tbody.innerHTML = `<tr><td style="color: var(--accent-rose); padding: 24px;">Lỗi truy vấn SQL: ${e.message}</td></tr>`;
  }
}
