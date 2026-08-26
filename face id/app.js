/**
 * VINATECH FACE ID & ACCESS CONTROL WEB APPLICATION
 * Core Client Controller & Interactive Blueprint Engine
 * Author: Vinatech IT & Automation Team
 */

// Multi-Language Translation Dictionary
const I18N = {
  vi: {
    nav_dashboard: "Bảng Điều Khiển",
    nav_map: "Mặt Bằng & Vị Trí",
    nav_boq: "Thống Kê Bản Vẽ ELV",
    nav_attendance: "Báo Cáo Chấm Công",
    nav_devices: "Danh Mục Thiết Bị",
    nav_personnel: "Nhân Sự & Phân Quyền",
    nav_sql: "Tra Cứu Database",
    nav_manual: "Sổ Tay Vận Hành (SOP)",
    btn_refresh: "Làm mới",
    stat_total_scans: "Tổng Lượt Sự Kiện",
    stat_realtime_synced: "Đồng bộ tự động SQL",
    stat_face_rate: "Tỷ Lệ Nhận Diện Face ID",
    stat_primary_method: "Phương thức sinh trắc chính",
    stat_total_devices: "Tổng Số Thiết Bị",
    stat_active_shift: "Ca Làm Việc Chuẩn",
    title_live_events: "Nhật Ký Quẹt Face ID & Cửa Thời Gian Thực",
    title_floorplans: "Mặt Bằng & Bản Đồ Phân Bổ Thiết Bị Face ID",
    title_boq: "Bảng Thống Kê Tổng Hợp Khối Lượng Thiết Bị ELV (Sheet 42/03)",
    title_attendance: "Báo Cáo Chấm Công Hàng Ngày (First In / Last Out)",
    btn_export_csv: "Xuất File CSV (Excel Chuẩn)",
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
    stat_realtime_synced: "Auto SQL Synced",
    stat_face_rate: "Face ID Match Rate",
    stat_primary_method: "Primary Biometric Method",
    stat_total_devices: "Total Devices",
    stat_active_shift: "Standard Work Shift",
    title_live_events: "Real-Time Face ID & Door Access Log",
    title_floorplans: "Interactive Floor Plans & Device Placement Map",
    title_attendance: "Daily Attendance Summary (First In / Last Out)",
    btn_export_csv: "Export CSV (Excel UTF-8)",
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
    stat_realtime_synced: "SQL 실시간 동기화",
    stat_face_rate: "Face ID 인증 비율",
    stat_primary_method: "주요 생체 인증",
    stat_total_devices: "총 설치 기기",
    stat_active_shift: "표준 근무조",
    title_live_events: "실시간 Face ID 및 출입문 로그",
    title_floorplans: "도면 기반 대화형 기기 배치도",
    title_attendance: "일일 근태 집계 (첫 출근 / 최종 퇴근)",
    btn_export_csv: "CSV 내보내기 (Excel)",
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
let currentFloor = 'ALL';
let factory3d = null;
let currentViewMode = '3d';

// Initialize Application
document.addEventListener('DOMContentLoaded', async () => {
  setupTheme();
  setupLiveClock();
  setupNavigation();
  setupLanguageSwitcher();
  setupModal();
  setupSqlStudio();
  
  await loadStaticData();
  renderAllViews();
  await refreshLiveStatus();

  // Periodic polling loop every 6 seconds
  setInterval(refreshLiveStatus, 6000);
});

// Setup Live Real-time Clock
function setupLiveClock() {
  const clockEl = document.getElementById('clock-time');
  function updateClock() {
    const now = new Date();
    const timeStr = now.toLocaleTimeString('vi-VN', { hour12: false });
    if (clockEl) clockEl.textContent = timeStr;
  }
  updateClock();
  setInterval(updateClock, 1000);
}

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

// Setup Theme (Dark / Light) with immediate SVG update & label sync
function setupTheme() {
  const btn = document.getElementById('theme-toggle-btn');
  const icon = document.getElementById('theme-icon');
  const label = document.getElementById('theme-label');
  
  const saved = localStorage.getItem('vnt_theme') || 'dark';
  applyTheme(saved);

  btn.addEventListener('click', () => {
    const curr = document.documentElement.getAttribute('data-theme');
    const next = curr === 'dark' ? 'light' : 'dark';
    applyTheme(next);
    localStorage.setItem('vnt_theme', next);
  });

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    if (theme === 'light') {
      if (icon) icon.textContent = '☀️';
      if (label) label.textContent = 'Sáng';
      btn.setAttribute('title', 'Đang ở chế độ Sáng (Ngày). Bấm để chuyển sang Tối (Đêm)');
    } else {
      if (icon) icon.textContent = '🌙';
      if (label) label.textContent = 'Tối';
      btn.setAttribute('title', 'Đang ở chế độ Tối (Đêm). Bấm để chuyển sang Sáng (Ngày)');
    }

    // Sync 3D Digital Twin background & fog
    if (factory3d && typeof factory3d.setTheme === 'function') {
      factory3d.setTheme(theme);
    }

    // Re-render floor map if visible to update SVG styling
    renderFloorMap(currentFloor);
  }
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

  document.getElementById('btn-refresh').addEventListener('click', async () => {
    const btn = document.getElementById('btn-refresh');
    btn.style.opacity = '0.6';
    btn.innerHTML = '⏳ Đang tải...';
    await refreshLiveStatus();
    if (document.getElementById('view-attendance').classList.contains('active')) {
      await loadAttendanceData();
    }
    setTimeout(() => {
      btn.style.opacity = '1';
      btn.innerHTML = '🔄 <span data-i18n="btn_refresh">Làm mới</span>';
      updateLanguage(currentLang);
    }, 400);
  });
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

  // View specific triggers
  if (viewId === 'floorplans') {
    if (factory3d) {
      setTimeout(() => factory3d.onWindowResize(), 60);
    }
    renderFloorMap(currentFloor === 'ALL' ? '1F' : currentFloor);
  } else if (viewId === 'attendance') {
    loadAttendanceData();
  }
}

// Setup Language Switcher
function setupLanguageSwitcher() {
  const select = document.getElementById('lang-select');
  if (select) {
    select.addEventListener('change', (e) => {
      currentLang = e.target.value;
      updateLanguage(currentLang);
    });
  }
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
        if (dot) {
          dot.style.background = 'var(--emerald)';
          dot.style.boxShadow = '0 0 10px var(--emerald)';
        }
        if (text) text.textContent = `HCP_DATA: Đã kết nối (${statusData.server}) — ${statusData.totalEvents} Sự kiện`;
      } else {
        if (dot) {
          dot.style.background = 'var(--amber)';
          dot.style.boxShadow = '0 0 10px var(--amber)';
        }
        if (text) text.textContent = `HCP_DATA: Bộ đệm (${statusData.totalEvents} sự kiện)`;
      }
    }

    if (eventsRes && eventsRes.ok) {
      liveEvents = await eventsRes.json();
      filterAndRenderDashboardEvents();
      const countEl = document.getElementById('live-event-count');
      if (countEl) countEl.textContent = `Hiển thị ${liveEvents.length} bản ghi gần nhất`;

      if (factory3d && liveEvents.length > 0) {
        const topEv = liveEvents[0];
        const matchDev = (appData.devices || []).find(d => 
          (topEv.DeviceName && (topEv.DeviceName.includes(d.id) || topEv.DeviceName.includes(d.code))) ||
          (topEv.ResourceName && (topEv.ResourceName.includes(d.id) || topEv.ResourceName.includes(d.code)))
        );
        if (matchDev) {
          factory3d.triggerEventAlert(matchDev.id, topEv);
        }
      }
    }

    if (statsRes && statsRes.ok) {
      const stats = await statsRes.json();
      const totalEl = document.getElementById('stat-total-scans');
      const rateEl = document.getElementById('stat-face-rate');
      if (totalEl) totalEl.textContent = stats.totalEvents + "+";
      if (rateEl) rateEl.textContent = stats.faceIdPercentage + "%";

      // Update Breakdown bars
      const total = stats.totalEvents || 1;
      const facePct = (stats.faceIdCount / total * 100).toFixed(1);
      const fingerPct = (stats.fingerCount / total * 100).toFixed(1);
      const cardPct = (stats.cardCount / total * 100).toFixed(1);

      const barFace = document.getElementById('bar-face');
      const barFinger = document.getElementById('bar-finger');
      const barCard = document.getElementById('bar-card');

      if (barFace) {
        barFace.style.width = facePct + "%";
        barFace.title = `Face ID: ${facePct}% (${stats.faceIdCount} lượt)`;
      }
      if (barFinger) {
        barFinger.style.width = fingerPct + "%";
        barFinger.title = `Vân tay: ${fingerPct}% (${stats.fingerCount} lượt)`;
      }
      if (barCard) {
        barCard.style.width = cardPct + "%";
        barCard.title = `Thẻ từ: ${cardPct}% (${stats.cardCount} lượt)`;
      }

      const valFace = document.getElementById('val-face-count');
      const valFinger = document.getElementById('val-finger-count');
      const valCard = document.getElementById('val-card-count');

      if (valFace) valFace.textContent = `${stats.faceIdCount} (${facePct}%)`;
      if (valFinger) valFinger.textContent = `${stats.fingerCount} (${fingerPct}%)`;
      if (valCard) valCard.textContent = `${stats.cardCount} (${cardPct}%)`;
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
  renderBoqTables();
  init3DEngine();
  setupModeSwitcher();
  setup3DControls();
  setupLayerFilters();
  setupAssetSearch();
  setupDrawerInspector();
  renderFloorTabs();
  renderFloorMap('ALL');
  setupDashboardFilters();
  setupAttendanceFilters();
  setupPersonnelFilters();
}

// Render Sheet 42/03 Official BOQ Tables
function renderBoqTables() {
  const container = document.getElementById('boq-tables-container');
  if (!container || !appData || !appData.drawingInfo || !appData.drawingInfo.summary) return;

  const summary = appData.drawingInfo.summary;

  const sections = [
    { key: 'networkPbx', title: 'I. HỆ THỐNG MẠNG IT & TỔNG ĐÀI (NETWORK & PBX SYSTEM)', icon: '📶', items: summary.networkPbx || [] },
    { key: 'cctv', title: 'II. HỆ THỐNG CAMERA GIÁM SÁT (CCTV SYSTEM — 81 CAM)', icon: '📹', items: summary.cctv || [] },
    { key: 'taAc', title: 'III. HỆ THỐNG KIỂM SOÁT CỬA & CHẤM CÔNG (TA/AC SYSTEM)', icon: '🚪', items: summary.taAc || [] },
    { key: 'pa', title: 'IV. HỆ THỐNG ÂM THANH THÔNG BÁO (PA SOUND SYSTEM — 96 LOA)', icon: '📢', items: summary.pa || [] }
  ];

  let html = '';
  sections.forEach(sec => {
    let rowsHtml = '';
    sec.items.forEach(it => {
      rowsHtml += `
        <tr>
          <td style="font-family: var(--font-mono); font-weight: 800; text-align: center; width: 40px;">${it.no}</td>
          <td><strong style="color: var(--text-title);">${it.item}</strong></td>
          <td style="font-size: 11.5px; color: var(--text-faint);">${it.model || '—'}</td>
          <td style="text-align: center; font-family: var(--font-mono); font-size: 11.5px;">${it.unit}</td>
          <td style="text-align: center;"><span class="boq-qty-pill">${it.qty < 10 ? '0' + it.qty : it.qty}</span></td>
        </tr>
      `;
    });

    html += `
      <div class="boq-section-card">
        <div class="boq-section-header">
          <h4 class="boq-section-title">
            <span>${sec.icon}</span> <span>${sec.title}</span>
          </h4>
          <span class="badge" style="background: rgba(99,102,241,0.15); color: var(--primary); font-weight: 800;">${sec.items.length} Hạng mục</span>
        </div>
        <div style="overflow-x: auto;">
          <table class="boq-table">
            <thead>
              <tr>
                <th style="text-align: center; width: 40px;">STT</th>
                <th>Tên Thiết Bị & Chủng Loại</th>
                <th>Quy Cách / Model Bản Vẽ</th>
                <th style="text-align: center;">ĐVT</th>
                <th style="text-align: center;">Số Lượng</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
          </table>
        </div>
      </div>
    `;
  });

  container.innerHTML = html;
}

// Initialize 3D Digital Twin Engine with All ELV Assets
function init3DEngine() {
  if (typeof Factory3DEngine !== 'undefined' && !factory3d) {
    const viewport = document.getElementById('factory-3d-viewport');
    if (viewport) {
      factory3d = new Factory3DEngine('factory-3d-viewport', {
        onDeviceClick: (item) => {
          openDeviceInspector(item);
        }
      });
      if (appData) {
        factory3d.syncAllAssets(appData);
      }
      const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
      factory3d.setTheme(currentTheme);
    }
  }
}

// Setup ELV Layer Filters (All, IT Racks, CCTV, Wi-Fi, PA, AC, TA, Barrier)
function setupLayerFilters() {
  const chips = document.querySelectorAll('.layer-chip');
  chips.forEach(chip => {
    chip.addEventListener('click', () => {
      chips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      const layer = chip.getAttribute('data-layer');
      if (factory3d) {
        factory3d.setDeviceLayerFilter(layer);
      }
      renderFloorMap(currentFloor === 'ALL' ? '1F' : currentFloor);
    });
  });
}

// Setup Quick Asset Search on 3D Map
function setupAssetSearch() {
  const searchInput = document.getElementById('map-asset-search');
  if (!searchInput) return;

  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    if (!query) return;

    const allPool = [
      ...(appData.devices || []),
      ...(appData.itRacks || []),
      ...(appData.cctvCameras || []),
      ...(appData.wifiAccessPoints || []),
      ...(appData.paSpeakers || [])
    ];

    const match = allPool.find(item => 
      (item.name && item.name.toLowerCase().includes(query)) ||
      (item.code && item.code.toLowerCase().includes(query)) ||
      (item.room && item.room.toLowerCase().includes(query)) ||
      (item.zone && item.zone.toLowerCase().includes(query)) ||
      (item.id && item.id.toLowerCase().includes(query))
    );

    if (match && factory3d) {
      factory3d.focusOnDevice(match.id);
      openDeviceInspector(match);
    }
  });
}

// Setup In-Viewport Quick Inspector Drawer
function setupDrawerInspector() {
  const closeBtn = document.getElementById('drawer-close-btn');
  const drawer = document.getElementById('drawer-device-inspector');
  if (closeBtn && drawer) {
    closeBtn.addEventListener('click', () => {
      drawer.classList.remove('active');
    });
  }
}

// Open In-Viewport Inspector Drawer (Supports AC, TA, Barrier, IT Rack, CCTV, Wi-Fi, PA)
window.openDeviceInspector = function(item) {
  const drawer = document.getElementById('drawer-device-inspector');
  const icon = document.getElementById('drawer-icon');
  const title = document.getElementById('drawer-title');
  const code = document.getElementById('drawer-code');
  const body = document.getElementById('drawer-body');

  if (!drawer || !item) return;

  icon.textContent = item.icon || (item.type === 'WIFI' ? '📶' : (item.type === 'PA' ? '📢' : '🚪'));
  title.textContent = item.name || 'Thiết bị ELV';
  code.textContent = `${item.code || item.id} • ${item.typeLabel || item.type || ''}`;

  let contentHtml = '';

  if (item.type === 'IT_RACK') {
    const equipList = (item.equipment || []).map(eq => `<li>${eq}</li>`).join('');
    contentHtml = `
      <div style="background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.3); border-radius: var(--radius-md); padding: 12px;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Vị trí:</span>
          <strong>${item.floorName} — ${item.room}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">IP Quản Trị:</span>
          <strong style="font-family: var(--font-mono); color: var(--emerald);">${item.ipAddress}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Nguồn Điện:</span>
          <span>${item.power || '220V UPS'}</span>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span style="color: var(--text-faint);">Nhiệt Độ RACK:</span>
          <strong style="color: #38bdf8;">${item.temp || '22.0°C'} (Ổn định)</strong>
        </div>
      </div>

      <div>
        <strong style="font-size: 12px; color: var(--text-title); display: block; margin-bottom: 6px;">Thiết Bị Bên Trong Tủ RACK:</strong>
        <ul style="padding-left: 18px; margin: 0; color: var(--text-muted); font-size: 12.5px; line-height: 1.6;">
          ${equipList}
        </ul>
      </div>

      <div style="display: flex; gap: 8px; margin-top: 4px;">
        <span class="badge badge-success">● Core Online</span>
        <span class="badge" style="background: rgba(6,182,212,0.15); color: #22d3ee; border: 1px solid rgba(6,182,212,0.3);">Fiber Backbone</span>
      </div>
    `;
  } else if (item.type === 'CCTV') {
    contentHtml = `
      <div style="background: rgba(6,182,212,0.1); border: 1px solid rgba(6,182,212,0.3); border-radius: var(--radius-md); padding: 12px;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Vị trí:</span>
          <strong>${item.floor} — ${item.name}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">IP Camera:</span>
          <strong style="font-family: var(--font-mono); color: #22d3ee;">${item.ipAddress}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Độ Phân Giải:</span>
          <strong>4.0 Megapixel (2560x1440) @ 30fps</strong>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span style="color: var(--text-faint);">Giao Thức:</span>
          <span>ONVIF Profile S / HikCentral NVR</span>
        </div>
      </div>

      <div style="position: relative; height: 130px; background: #0b1120; border-radius: var(--radius-sm); border: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; justify-content: center; overflow: hidden;">
        <span style="position: absolute; top: 8px; left: 8px; font-size: 11px; background: rgba(244,63,94,0.85); color: #fff; padding: 2px 6px; border-radius: 4px; font-weight: 800;">● LIVE CAM</span>
        <div style="text-align: center; color: var(--text-faint);">
          <span style="font-size: 28px;">📹</span>
          <div style="font-size: 11.5px; margin-top: 4px;">Kênh luồng RTSP / HikCentral Stream</div>
        </div>
      </div>

      <div style="display: flex; gap: 8px;">
        <span class="badge badge-success">● Đang Ghi Hình (Recording)</span>
        <span class="badge badge-face">AI Motion Ready</span>
      </div>
    `;
  } else if (item.type === 'WIFI') {
    contentHtml = `
      <div style="background: rgba(59,130,246,0.1); border: 1px solid rgba(59,130,246,0.3); border-radius: var(--radius-md); padding: 12px;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Vị trí:</span>
          <strong>${item.floor} — ${item.room}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">IP AP:</span>
          <strong style="font-family: var(--font-mono); color: #38bdf8;">${item.ipAddress}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Băng Tần:</span>
          <strong>Dual-Band Wi-Fi 6 (2.4GHz + 5GHz)</strong>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span style="color: var(--text-faint);">Thiết Bị Kết Nối:</span>
          <strong style="color: var(--emerald);">${item.clients || 20} Clients Active</strong>
        </div>
      </div>

      <div style="display: flex; gap: 8px;">
        <span class="badge badge-success">● Wi-Fi 6 Active</span>
        <span class="badge" style="background: rgba(59,130,246,0.15); color: #60a5fa;">SSID: VINATECH_CORP</span>
      </div>
    `;
  } else if (item.type === 'PA') {
    contentHtml = `
      <div style="background: rgba(168,85,247,0.1); border: 1px solid rgba(168,85,247,0.3); border-radius: var(--radius-md); padding: 12px;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Vùng Phát Thanh:</span>
          <strong>${item.zone}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Số Lượng Loa:</span>
          <strong style="color: #c084fc;">${item.qty} Loa (${item.type})</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Tuyến Cáp:</span>
          <span>100V Line từ Tủ RACK PA (2F)</span>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span style="color: var(--text-faint);">Trạng Thái:</span>
          <strong style="color: var(--emerald);">Sẵn Sàng Phát Nhạc & Chuông Ca</strong>
        </div>
      </div>

      <div style="display: flex; gap: 8px;">
        <span class="badge badge-success">● Zone Ready</span>
        <span class="badge" style="background: rgba(168,85,247,0.15); color: #c084fc;">BGM & Paging</span>
      </div>
    `;
  } else {
    contentHtml = `
      <div style="background: rgba(99,102,241,0.1); border: 1px solid rgba(99,102,241,0.3); border-radius: var(--radius-md); padding: 12px;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Vị trí:</span>
          <strong>${item.floorName || item.floor} — ${item.room}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Khóa/Cổng:</span>
          <strong style="color: var(--primary);">${item.lockType || 'Khóa Từ / Flap'}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">IP Thiết Bị:</span>
          <strong style="font-family: var(--font-mono);">${item.ipAddress}</strong>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span style="color: var(--text-faint);">Tủ Rack Quản Lý:</span>
          <span style="font-family: var(--font-mono);">${item.controller}</span>
        </div>
      </div>

      <div style="display: flex; gap: 8px;">
        <span class="badge badge-success">● Trực Tuyến (&lt;10ms)</span>
        <span class="badge badge-face">Face ID Ready</span>
      </div>

      <button class="btn btn-primary" style="width: 100%; padding: 8px 12px; font-size: 12.5px; margin-top: 4px;" onclick="simulateDoorAction('${item.code}', 'Mở Cửa 5s')">
        🔓 Kích Hoạt Mở Khóa Từ Xa (5s)
      </button>
    `;
  }

  body.innerHTML = contentHtml;
  drawer.classList.add('active');
};

// Setup 3D / 2D Hybrid Mode Switcher
function setupModeSwitcher() {
  const btn3D = document.getElementById('btn-mode-3d');
  const btn2D = document.getElementById('btn-mode-2d');
  const cont3D = document.getElementById('container-3d-wrapper');
  const cont2D = document.getElementById('container-2d-wrapper');

  if (btn3D && btn2D && cont3D && cont2D) {
    btn3D.addEventListener('click', () => {
      btn3D.classList.add('active');
      btn2D.classList.remove('active');
      cont3D.style.display = 'block';
      cont2D.style.display = 'none';
      currentViewMode = '3d';
      if (factory3d) {
        setTimeout(() => factory3d.onWindowResize(), 50);
      }
    });

    btn2D.addEventListener('click', () => {
      btn2D.classList.add('active');
      btn3D.classList.remove('active');
      cont3D.style.display = 'none';
      cont2D.style.display = 'block';
      currentViewMode = '2d';
      renderFloorMap(currentFloor === 'ALL' ? '1F' : currentFloor);
    });
  }
}

// Setup 3D HUD Controls (Rotate, Exploded, X-Ray, Reset)
function setup3DControls() {
  const btnRotate = document.getElementById('btn-3d-rotate');
  const btnExploded = document.getElementById('btn-3d-exploded');
  const btnXray = document.getElementById('btn-3d-xray');
  const btnReset = document.getElementById('btn-3d-reset');

  if (btnRotate) {
    btnRotate.addEventListener('click', () => {
      if (!factory3d) return;
      const isRotating = factory3d.toggleAutoRotate();
      btnRotate.classList.toggle('active', isRotating);
    });
  }

  if (btnExploded) {
    btnExploded.addEventListener('click', () => {
      if (!factory3d) return;
      const isExp = factory3d.toggleExplodedView();
      btnExploded.classList.toggle('active', isExp);
    });
  }

  if (btnXray) {
    btnXray.addEventListener('click', () => {
      if (!factory3d) return;
      const isX = factory3d.toggleXRay();
      btnXray.classList.toggle('active', isX);
    });
  }

  if (btnReset) {
    btnReset.addEventListener('click', () => {
      if (!factory3d) return;
      factory3d.resetCamera();
    });
  }
}

// Filter and Render Dashboard Events Table
function filterAndRenderDashboardEvents() {
  const search = document.getElementById('dashboard-search');
  const devSelect = document.getElementById('filter-device');
  const authSelect = document.getElementById('filter-auth');

  const q = search ? search.value.toLowerCase() : '';
  const dev = devSelect ? devSelect.value : '';
  const auth = authSelect ? authSelect.value : '';

  const filtered = liveEvents.filter(e => {
    const matchQ = !q || (e.PersonName || '').toLowerCase().includes(q) || (e.EmployeeID || '').toLowerCase().includes(q) || (e.DeviceName || '').toLowerCase().includes(q);
    const matchDev = !dev || (e.DeviceName || '') === dev;
    let matchAuth = true;
    if (auth) {
      const authType = (e.AuthenticationType || '').toLowerCase();
      matchAuth = authType.includes(auth);
    }
    return matchQ && matchDev && matchAuth;
  });

  renderDashboardEvents(filtered);
}

function renderDashboardEvents(events) {
  const tbody = document.getElementById('dashboard-events-tbody');
  if (!tbody) return;
  tbody.innerHTML = '';

  if (!events || events.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-faint); padding: 28px;">Chưa có dữ liệu sự kiện phù hợp</td></tr>`;
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
      <td><span style="font-family: var(--font-mono); font-weight: 800; color: var(--primary);">${e.EmployeeID || '—'}</span></td>
      <td><strong>${e.PersonName || 'Chưa định danh'}</strong></td>
      <td><span class="badge" style="background: rgba(99,102,241,0.1); border: 1px solid var(--card-border); color: var(--text-muted);">${e.Department || 'Chung'}</span></td>
      <td><span style="font-family: var(--font-mono); color: var(--text-muted); font-size: 12.5px;">${e.AccessDate || ''} ${e.AccessTime || ''}</span></td>
      <td><strong>${e.DeviceName || 'Device'}</strong> <span style="font-size: 11px; color: var(--text-faint);">(${e.ResourceName || ''})</span></td>
      <td><span class="badge ${badgeClass}">${authLabel}</span></td>
      <td><span class="badge badge-success">✓ Hợp Lệ</span></td>
    `;
    tbody.appendChild(tr);
  });
}

function setupDashboardFilters() {
  const search = document.getElementById('dashboard-search');
  const devSelect = document.getElementById('filter-device');
  const authSelect = document.getElementById('filter-auth');

  if (search) search.addEventListener('input', filterAndRenderDashboardEvents);
  if (devSelect) devSelect.addEventListener('change', filterAndRenderDashboardEvents);
  if (authSelect) authSelect.addEventListener('change', filterAndRenderDashboardEvents);
}

// Floor Plans Map & 3D Synchronization
function renderFloorTabs() {
  const tabs = document.querySelectorAll('.floor-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      currentFloor = tab.getAttribute('data-floor');
      
      // Update 3D Digital Twin
      if (factory3d) {
        factory3d.setFloorView(currentFloor);
      }
      // Update 2D CAD Blueprint
      renderFloorMap(currentFloor === 'ALL' ? '1F' : currentFloor);
    });
  });
}

function renderFloorMap(floor) {
  const container = document.getElementById('floor-blueprint-wrap');
  if (!container) return;

  const actualFloor = floor === 'ALL' ? '1F' : floor;
  const devicesOnFloor = (appData.devices || []).filter(d => d.floor === actualFloor);
  const racksOnFloor = (appData.itRacks || []).filter(r => r.floor === actualFloor);
  const camsOnFloor = (appData.cctvCameras || []).filter(c => c.floor === actualFloor);
  const wifisOnFloor = (appData.wifiAccessPoints || []).filter(w => w.floor === actualFloor);
  const paOnFloor = (appData.paSpeakers || []).filter(p => p.floor === actualFloor);

  let floorBgBoxes = '';
  
  if (actualFloor === '1F') {
    floorBgBoxes = `
      <!-- Tầng 1 Rooms with dedicated top header pills -->
      <!-- Room 1: Kho & Dock -->
      <rect x="40" y="45" width="220" height="350" class="room-box" rx="14"/>
      <rect x="52" y="55" width="196" height="28" class="room-header-badge" rx="6"/>
      <text x="150" y="70" class="room-label">📦 Kho 1 (104) & Dock 105</text>

      <!-- Room 2: Locker Nữ -->
      <rect x="280" y="45" width="250" height="160" class="room-box" rx="14"/>
      <rect x="292" y="55" width="226" height="28" class="room-header-badge" rx="6"/>
      <text x="405" y="70" class="room-label">🧪 Locker Nữ (136) / QC Room</text>

      <!-- Room 3: Căn Tin -->
      <rect x="280" y="235" width="250" height="160" class="room-box" rx="14"/>
      <rect x="292" y="245" width="226" height="28" class="room-header-badge" rx="6"/>
      <text x="405" y="260" class="room-label">🍽️ Căn Tin & P. Nghỉ Ca (115A)</text>

      <!-- Room 4: Điều Khiển -->
      <rect x="550" y="45" width="190" height="350" class="room-box" rx="14"/>
      <rect x="560" y="55" width="170" height="28" class="room-header-badge" rx="6"/>
      <text x="645" y="70" class="room-label">🎛️ P. Điều Khiển (128)</text>

      <!-- Room 5: Sảnh Chính -->
      <rect x="760" y="45" width="200" height="350" class="room-box" rx="14"/>
      <rect x="770" y="55" width="180" height="28" class="room-header-badge" rx="6"/>
      <text x="860" y="70" class="room-label">🏛️ Sảnh Chính & Showroom (101)</text>
    `;
  } else if (actualFloor === '1.5F') {
    floorBgBoxes = `
      <rect x="180" y="50" width="640" height="340" class="room-box" rx="16"/>
      <rect x="200" y="65" width="600" height="34" class="room-header-badge" rx="8"/>
      <text x="500" y="83" class="room-label">🏢 Khối Văn Phòng 1.5F (P. 201 & P. Giám Đốc 202)</text>
    `;
  } else if (actualFloor === '2F') {
    floorBgBoxes = `
      <!-- IT Room -->
      <rect x="100" y="50" width="370" height="340" class="room-box" rx="16"/>
      <rect x="120" y="65" width="330" height="34" class="room-header-badge" rx="8"/>
      <text x="285" y="83" class="room-label">💻 P. IT & Server Room (304) [Rack Main 42U + PA 27U]</text>

      <!-- Văn Phòng 2F -->
      <rect x="495" y="50" width="405" height="340" class="room-box" rx="16"/>
      <rect x="515" y="65" width="365" height="34" class="room-header-badge" rx="8"/>
      <text x="697" y="83" class="room-label">👔 Văn Phòng 2F (302: HR, Kế toán, Mua hàng, Giám đốc 303)</text>
    `;
  } else if (actualFloor === 'PARKING') {
    floorBgBoxes = `
      <!-- Nhà Bảo Vệ 1 (Cổng Chính) -->
      <rect x="760" y="45" width="200" height="150" class="room-box" rx="14"/>
      <rect x="772" y="55" width="176" height="26" class="room-header-badge" rx="6"/>
      <text x="860" y="68" class="room-label">🛡️ Nhà Bảo Vệ 1 [Cổng Chính - RACK_06]</text>

      <!-- Nhà Bảo Vệ 2 (Cổng Logistics) -->
      <rect x="40" y="45" width="200" height="150" class="room-box" rx="14"/>
      <rect x="52" y="55" width="176" height="26" class="room-header-badge" rx="6"/>
      <text x="140" y="68" class="room-label">🚛 Nhà Bảo Vệ 2 [Cổng Phụ - RACK_07]</text>

      <!-- Nhà Bảo Vệ 3 & Cổng Nhà Xe -->
      <rect x="40" y="240" width="200" height="150" class="room-box" rx="14"/>
      <rect x="52" y="250" width="176" height="26" class="room-header-badge" rx="6"/>
      <text x="140" y="263" class="room-label">🅿️ Nhà Bảo Vệ 3 [Nhà Xe - RACK_08]</text>

      <!-- Flap Barrier Vào -->
      <rect x="260" y="45" width="480" height="150" class="room-box" rx="14"/>
      <rect x="272" y="55" width="456" height="26" class="room-header-badge" rx="6"/>
      <text x="500" y="68" class="room-label">🟢 5 Làn Flap Barrier CHIỀU VÀO Nhà Xưởng (AC-10 -> AC-14)</text>

      <!-- Flap Barrier Ra -->
      <rect x="260" y="240" width="480" height="150" class="room-box" rx="14"/>
      <rect x="272" y="250" width="456" height="26" class="room-header-badge" rx="6"/>
      <text x="500" y="263" class="room-label">🔴 5 Làn Flap Barrier CHIỀU RA Nhà Xe (AC-15 -> AC-19)</text>

      <!-- Tiện ích Khuôn Viên: Trạm Biến Áp / PCCC / Xử Lý Nước Thải -->
      <rect x="760" y="240" width="200" height="150" class="room-box" rx="14"/>
      <rect x="772" y="250" width="176" height="26" class="room-header-badge" rx="6"/>
      <text x="860" y="263" class="room-label">⚡ Trạm Biến Áp & Bể PCCC & Utility</text>
    `;
  }

  // Generate Pins for Devices (AC, TA, Barrier)
  let pinsSvg = '';
  devicesOnFloor.forEach(d => {
    const isAc = d.type === 'AC';
    const isBarrier = d.type === 'BARRIER';
    let pinClass = isAc ? 'pin-ac' : (isBarrier ? 'pin-barrier' : 'pin-ta');

    pinsSvg += `
      <g class="device-pin" onclick="openDeviceInspector(appData.devices.find(x => x.id === '${d.id}'))" transform="translate(${d.x * 10}, ${d.y * 4.4})">
        <rect x="-28" y="-14" width="56" height="28" rx="14" class="pin-pill ${pinClass}"></rect>
        <text x="0" y="4" text-anchor="middle" font-size="11" font-family="'JetBrains Mono', monospace" font-weight="800" fill="#ffffff" pointer-events="none" letter-spacing="0.2px">${d.code}</text>
        <title>${d.code}: ${d.name} (${d.typeLabel})</title>
      </g>
    `;
  });

  // Generate Pins for IT Racks
  racksOnFloor.forEach(r => {
    pinsSvg += `
      <g class="device-pin" onclick="openDeviceInspector(appData.itRacks.find(x => x.id === '${r.id}'))" transform="translate(${r.x * 10}, ${r.y * 4.4})">
        <rect x="-38" y="-14" width="76" height="28" rx="14" class="pin-pill pin-rack"></rect>
        <text x="0" y="4" text-anchor="middle" font-size="10" font-family="'JetBrains Mono', monospace" font-weight="800" fill="#ffffff" pointer-events="none">🖥️ ${r.code}</text>
        <title>${r.name} (${r.ipAddress})</title>
      </g>
    `;
  });

  // Generate Pins for CCTV Cameras
  camsOnFloor.forEach(c => {
    pinsSvg += `
      <g class="device-pin" onclick="openDeviceInspector(appData.cctvCameras.find(x => x.id === '${c.id}'))" transform="translate(${c.x * 10}, ${c.y * 4.4})">
        <circle cx="0" cy="0" r="14" class="pin-cctv"></circle>
        <text x="0" y="4" text-anchor="middle" font-size="11" pointer-events="none">📹</text>
        <title>${c.code}: ${c.name}</title>
      </g>
    `;
  });

  // Generate Pins for Wi-Fi APs
  wifisOnFloor.forEach(w => {
    pinsSvg += `
      <g class="device-pin" onclick="openDeviceInspector(appData.wifiAccessPoints.find(x => x.id === '${w.id}'))" transform="translate(${w.x * 10}, ${w.y * 4.4})">
        <circle cx="0" cy="0" r="14" class="pin-wifi"></circle>
        <text x="0" y="4" text-anchor="middle" font-size="11" pointer-events="none">📶</text>
        <title>${w.code}: ${w.name}</title>
      </g>
    `;
  });

  // Generate Pins for PA Speakers
  paOnFloor.forEach(p => {
    pinsSvg += `
      <g class="device-pin" onclick="openDeviceInspector(appData.paSpeakers.find(x => x.id === '${p.id}'))" transform="translate(${p.x * 10}, ${p.y * 4.4})">
        <circle cx="0" cy="0" r="14" class="pin-pa"></circle>
        <text x="0" y="4" text-anchor="middle" font-size="11" pointer-events="none">📢</text>
        <title>${p.code}: ${p.name} (${p.qty} Loa)</title>
      </g>
    `;
  });

  const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
  const gridStroke = isDark ? 'rgba(99,102,241,0.07)' : 'rgba(99,102,241,0.06)';

  container.innerHTML = `
    <svg class="blueprint-svg" viewBox="0 0 1000 440" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <pattern id="grid-pattern" width="40" height="40" patternUnits="userSpaceOnUse">
          <path d="M 40 0 L 0 0 0 40" fill="none" stroke="${gridStroke}" stroke-width="1"/>
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#grid-pattern)" />
      ${floorBgBoxes}
      ${pinsSvg}
    </svg>
  `;
}

// Modal inspection
function setupModal() {
  const modal = document.getElementById('device-modal');
  const closeBtn = document.getElementById('modal-close-btn');

  if (closeBtn) closeBtn.addEventListener('click', () => modal.classList.remove('active'));
  if (modal) {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.classList.remove('active');
    });
  }
}

window.openDeviceModal = function(devId) {
  const dev = (appData.devices || []).find(d => d.id === devId);
  if (!dev) return;

  document.getElementById('modal-icon').textContent = dev.icon || '🚪';
  document.getElementById('modal-device-name').textContent = dev.name;
  document.getElementById('modal-device-code').textContent = `Mã TB: ${dev.code} | ${dev.typeLabel}`;

  const body = document.getElementById('modal-body');
  body.innerHTML = `
    <div style="display: grid; grid-template-columns: 140px 1fr; gap: 12px; background: var(--bg-subtle); padding: 18px; border-radius: var(--radius-md); border: 1px solid var(--card-border);">
      <span style="color: var(--text-faint); font-weight: 700;">Vị trí lắp đặt:</span>
      <strong>${dev.floorName} — ${dev.room}</strong>

      <span style="color: var(--text-faint); font-weight: 700;">Chức năng chính:</span>
      <strong>${dev.typeLabel}</strong>

      <span style="color: var(--text-faint); font-weight: 700;">Cơ cấu khóa/cổng:</span>
      <span style="color: var(--primary); font-weight: 800;">${dev.lockType}</span>

      <span style="color: var(--text-faint); font-weight: 700;">Phụ kiện an toàn:</span>
      <span>${(dev.accessories || []).join(' • ')}</span>

      <span style="color: var(--text-faint); font-weight: 700;">Tủ RACK quản lý:</span>
      <span style="font-family: var(--font-mono); font-weight: 700;">${dev.controller}</span>

      <span style="color: var(--text-faint); font-weight: 700;">Số Serial / IP:</span>
      <span style="font-family: var(--font-mono); font-weight: 600;">${dev.serialNo} (${dev.ipAddress})</span>
    </div>
    
    <div style="display: flex; gap: 10px; margin-top: 6px; flex-wrap: wrap;">
      <span class="badge badge-success">● Trực Tuyến (Online &lt;10ms)</span>
      <span class="badge badge-face">Face ID Ready (&lt;0.3s)</span>
      <span class="badge badge-card">${dev.floor}</span>
    </div>

    <!-- Interactive Remote Actions Bar -->
    <div class="modal-actions-bar">
      <button class="btn btn-primary" onclick="simulateDoorAction('${dev.code}', 'Mở Cửa 5s')">
        🔓 Mở Cửa 5 Giây
      </button>
      <button class="btn btn-secondary" onclick="simulateDoorAction('${dev.code}', 'Giữ Mở Cửa')">
        🟢 Giữ Mở Thường Trực
      </button>
      <button class="btn btn-danger" onclick="simulateDoorAction('${dev.code}', 'Khóa Cứng Khẩn Cấp')">
        🔒 Khóa Cứng Khẩn Cấp
      </button>
      <a href="https://192.168.184.250/#/portal" target="_blank" class="btn btn-secondary" style="text-decoration: none; font-size: 12px;">
        🌐 Web HikCentral
      </a>
    </div>
    <div id="modal-action-feedback" style="font-size: 12.5px; font-weight: 700; color: var(--emerald); display: none; margin-top: 8px;"></div>
  `;

  document.getElementById('device-modal').classList.add('active');
};

window.simulateDoorAction = function(devCode, actionName) {
  const fb = document.getElementById('modal-action-feedback');
  if (fb) {
    fb.style.display = 'block';
    fb.textContent = `⚡ [Lệnh Gửi Thành Công]: Đã kích hoạt "${actionName}" tới thiết bị ${devCode} qua giao thức HCP Control.`;
    setTimeout(() => {
      fb.style.display = 'none';
    }, 4500);
  }
};

// Render Devices Table View
function renderDevicesTable() {
  const tbody = document.getElementById('devices-tbody');
  const searchInput = document.getElementById('device-search');
  const filterType = document.getElementById('device-type-filter');

  const render = () => {
    if (!tbody) return;
    tbody.innerHTML = '';
    const q = searchInput ? searchInput.value.toLowerCase() : '';
    const type = filterType ? filterType.value : '';

    const filtered = (appData.devices || []).filter(d => {
      const matchQ = d.name.toLowerCase().includes(q) || d.code.toLowerCase().includes(q) || d.room.toLowerCase().includes(q) || d.lockType.toLowerCase().includes(q);
      const matchType = !type || d.type === type;
      return matchQ && matchType;
    });

    filtered.forEach(d => {
      const tr = document.createElement('tr');
      tr.style.cursor = 'pointer';
      tr.onclick = () => window.openDeviceModal(d.id);

      tr.innerHTML = `
        <td><strong style="color: var(--primary); font-family: var(--font-mono); font-weight: 800;">${d.code}</strong></td>
        <td><strong>${d.name}</strong><br><span style="font-size: 11px; color: var(--text-faint);">${d.room}</span></td>
        <td><span class="badge" style="background: rgba(99,102,241,0.1); border: 1px solid var(--card-border); color: var(--text-muted);">${d.floor}</span></td>
        <td><span class="badge ${d.type === 'AC' ? 'badge-face' : (d.type === 'BARRIER' ? 'badge-card' : 'badge-finger')}">${d.typeLabel}</span></td>
        <td>${d.lockType}</td>
        <td style="font-size: 12px; color: var(--text-muted);">${(d.accessories || []).join(', ')}</td>
        <td><span style="font-family: var(--font-mono); font-size: 12px;">${d.controller}</span></td>
        <td><span style="font-family: var(--font-mono); color: var(--text-faint);">${d.serialNo}</span></td>
      `;
      tbody.appendChild(tr);
    });
  };

  if (searchInput) searchInput.addEventListener('input', render);
  if (filterType) filterType.addEventListener('change', render);
  render();
}

// Render Personnel Table View
function renderPersonnelTable() {
  const tbody = document.getElementById('personnel-tbody');
  const search = document.getElementById('emp-search');
  const deptFilter = document.getElementById('emp-dept-filter');

  const render = () => {
    if (!tbody) return;
    tbody.innerHTML = '';
    const q = search ? search.value.toLowerCase() : '';
    const dept = deptFilter ? deptFilter.value : '';

    const filtered = (appData.employees || []).filter(e => {
      const matchQ = e.name.toLowerCase().includes(q) || e.id.includes(q) || e.dept.toLowerCase().includes(q);
      const matchDept = !dept || e.dept === dept;
      return matchQ && matchDept;
    });

    filtered.forEach(e => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><span style="font-family: var(--font-mono); font-weight: 800; color: var(--primary);">${e.id}</span></td>
        <td><strong>${e.name}</strong></td>
        <td><span class="badge" style="background: rgba(99,102,241,0.12); border: 1px solid var(--card-border); color: var(--text-muted);">${e.dept}</span></td>
        <td>${e.role}</td>
        <td>${e.face ? '<span class="badge badge-success">✓ Đã Nạp Mẫu</span>' : '<span class="badge badge-warn">Chưa Đăng Ký</span>'}</td>
        <td><span style="font-family: var(--font-mono); font-size: 12.5px; color: var(--cyan); font-weight: 800;">${e.access}</span></td>
        <td><span class="badge" style="background: rgba(16,185,129,0.12); color: var(--emerald); border: 1px solid rgba(16,185,129,0.3);">${e.attGroup}</span></td>
      `;
      tbody.appendChild(tr);
    });
  };

  if (search) search.addEventListener('input', renderPersonnelTable);
  if (deptFilter) deptFilter.addEventListener('change', renderPersonnelTable);
  render();
}

function setupPersonnelFilters() {
  const search = document.getElementById('emp-search');
  const deptFilter = document.getElementById('emp-dept-filter');
  if (search) search.addEventListener('input', renderPersonnelTable);
  if (deptFilter) deptFilter.addEventListener('change', renderPersonnelTable);
}

// Attendance View
let currentAttendanceList = [];

async function loadAttendanceData() {
  const dateInput = document.getElementById('att-date-picker');
  const tbody = document.getElementById('attendance-tbody');

  if (!dateInput.value) {
    dateInput.value = new Date().toISOString().slice(0, 10);
  }

  if (tbody) {
    tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-faint); padding: 28px;">Đang tổng hợp dữ liệu chấm công ngày ${dateInput.value}...</td></tr>`;
  }

  try {
    const res = await fetch(`/api/attendance?date=${dateInput.value}`);
    if (res.ok) {
      currentAttendanceList = await res.json();
      renderAttendanceTable();
    }
  } catch (e) {
    console.warn("Attendance load error:", e);
  }
}

function renderAttendanceTable() {
  const tbody = document.getElementById('attendance-tbody');
  const deptFilter = document.getElementById('att-dept-filter') ? document.getElementById('att-dept-filter').value : '';
  const statusFilter = document.getElementById('att-status-filter') ? document.getElementById('att-status-filter').value : '';
  if (!tbody) return;
  tbody.innerHTML = '';

  const filtered = currentAttendanceList.filter(item => {
    const matchDept = !deptFilter || item.department === deptFilter;
    const matchStatus = !statusFilter || item.status === statusFilter;
    return matchDept && matchStatus;
  });

  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-faint); padding: 28px;">Không có dữ liệu chấm công cho bộ lọc đã chọn</td></tr>`;
    return;
  }

  filtered.forEach(item => {
    const tr = document.createElement('tr');
    let statusBadge = '<span class="badge badge-success">✓ Đúng Giờ</span>';
    if (item.status === 'Late Arrival') {
      statusBadge = '<span class="badge badge-warn">⚠️ Đi Muộn</span>';
    } else if (item.status === 'Early Departure') {
      statusBadge = '<span class="badge badge-card">⚡ Về Sớm</span>';
    }

    tr.innerHTML = `
      <td><span style="font-family: var(--font-mono); font-weight: 800; color: var(--primary);">${item.employeeId}</span></td>
      <td><strong>${item.personName}</strong></td>
      <td><span class="badge" style="background: rgba(99,102,241,0.1); border: 1px solid var(--card-border); color: var(--text-muted);">${item.department || '—'}</span></td>
      <td><span style="font-family: var(--font-mono);">${item.date}</span></td>
      <td><strong style="color: var(--emerald); font-family: var(--font-mono); font-size: 14px;">${item.firstCheckIn}</strong></td>
      <td><span style="font-size: 11.5px; color: var(--text-faint);">${item.checkInDevice || '—'}</span></td>
      <td><strong style="color: var(--cyan); font-family: var(--font-mono); font-size: 14px;">${item.lastCheckOut}</strong></td>
      <td><span style="font-size: 11.5px; color: var(--text-faint);">${item.checkOutDevice || '—'}</span></td>
      <td><span style="font-weight: 800; font-family: var(--font-mono);">${item.totalScans}</span></td>
      <td>${statusBadge}</td>
    `;
    tbody.appendChild(tr);
  });
}

function setupAttendanceFilters() {
  const datePicker = document.getElementById('att-date-picker');
  const deptFilter = document.getElementById('att-dept-filter');
  const statusFilter = document.getElementById('att-status-filter');
  const exportBtn = document.getElementById('btn-export-attendance');

  if (datePicker) datePicker.addEventListener('change', loadAttendanceData);
  if (deptFilter) deptFilter.addEventListener('change', renderAttendanceTable);
  if (statusFilter) statusFilter.addEventListener('change', renderAttendanceTable);

  if (exportBtn) {
    exportBtn.addEventListener('click', () => {
      exportAttendanceToCsv();
    });
  }
}

// Export attendance table to CSV with UTF-8 BOM
function exportAttendanceToCsv() {
  if (!currentAttendanceList || currentAttendanceList.length === 0) {
    alert("Không có dữ liệu chấm công để xuất!");
    return;
  }

  const dateVal = document.getElementById('att-date-picker').value || 'export';
  let csvContent = "\uFEFFMã NV,Họ và Tên,Phòng Ban,Ngày,Giờ Đến (In),Cửa Đến,Giờ Về (Out),Cửa Về,Tổng Số Lần Quẹt,Trạng Thái\n";

  currentAttendanceList.forEach(row => {
    const line = [
      `"${row.employeeId}"`,
      `"${row.personName}"`,
      `"${row.department}"`,
      `"${row.date}"`,
      `"${row.firstCheckIn}"`,
      `"${row.checkInDevice}"`,
      `"${row.lastCheckOut}"`,
      `"${row.checkOutDevice}"`,
      `"${row.totalScans}"`,
      `"${row.status}"`
    ].join(",");
    csvContent += line + "\n";
  });

  const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.setAttribute("href", url);
  link.setAttribute("download", `Bao_Cao_Cham_Cong_Vinatech_${dateVal}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

// Render SOP Training Manual Cards
function renderSopCards() {
  const container = document.getElementById('sop-cards-container');
  if (!container) return;
  container.innerHTML = '';

  (appData.sopSteps || []).forEach(s => {
    const card = document.createElement('div');
    card.className = 'sop-card';
    card.innerHTML = `
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <div class="sop-step-badge">${s.step}</div>
          <span style="font-size: 22px;">${s.icon}</span>
        </div>
        <span class="badge" style="background: rgba(99,102,241,0.15); color: var(--primary); border: 1px solid rgba(99,102,241,0.3); font-size: 11px;">${s.slides}</span>
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

  const runBtn = document.getElementById('btn-run-sql');
  if (runBtn) runBtn.addEventListener('click', runCustomSql);
}

async function runCustomSql() {
  const sql = document.getElementById('sql-input').value.trim();
  const thead = document.getElementById('sql-results-thead');
  const tbody = document.getElementById('sql-results-tbody');

  if (!thead || !tbody) return;
  thead.innerHTML = '';
  tbody.innerHTML = `<tr><td style="text-align: center; color: var(--text-faint); padding: 28px;">Đang truy vấn CSDL HCP_DATA...</td></tr>`;

  try {
    const res = await fetch('/api/events?limit=50');
    if (res.ok) {
      const data = await res.json();
      if (data.length === 0) {
        tbody.innerHTML = `<tr><td style="text-align: center; color: var(--text-faint); padding: 28px;">0 kết quả</td></tr>`;
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
    tbody.innerHTML = `<tr><td style="color: var(--rose); padding: 28px;">Lỗi truy vấn SQL: ${e.message}</td></tr>`;
  }
}
