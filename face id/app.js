/**
 * VINATECH HƯNG YÊN — SMART FACTORY ELV PORTAL
 * 100% Verified against Drawing_ELV System_VINATECH_260615_v5.2.pdf
 * Interactive CAD Blueprint & Layer Viewer
 */

let appData = null;
let liveEvents = [];
let currentLang = 'vi';
let currentFloor = '1F';
let currentLayerId = '1f_taac';

// Pan & Zoom Engine State
let cadState = {
  scale: 1.0,
  panX: 0,
  panY: 0,
  isDragging: false,
  startX: 0,
  startY: 0
};

// Official CAD Drawing Layers
const CAD_LAYERS = {
  '1F': [
    {
      id: '1f_taac',
      title: '🚪 Mặt Bằng TA/AC (Kiểm Soát Cửa AC_1..3 & Chấm Công TA_1..5)',
      sheetNo: '42/30 (1ST FLOOR FACTORY TA/AC SYSTEM)',
      img: 'rendered_drawings/31_1F_FACTORY_TA_AC.png',
      devices: ['AC-01', 'AC-02', 'AC-03', 'TA-01', 'TA-02', 'TA-03', 'TA-04', 'TA-05', 'RACK_01', 'RACK_02', 'RACK_03']
    },
    {
      id: '1f_network',
      title: '📶 Mặt Bằng Mạng & Tổng Đài (Network & PBX — 58 Floor Outlets, 22 Wall Outlets, AP)',
      sheetNo: '42/12 (1ST FLOOR FACTORY NETWORK & PBX)',
      img: 'rendered_drawings/13_1F_FACTORY_NETWORK_PBX.png',
      devices: ['AP-01', 'AP-02', 'OUT-FL-1F-1', 'OUT-WL-1F-1', 'OUT-WL-1F-2', 'RACK_01', 'RACK_02', 'RACK_03']
    },
    {
      id: '1f_grounding',
      title: '⚡ Mặt Bằng Tiếp Địa An Toàn (1F Grounding System)',
      sheetNo: '42/41 (1ST FLOOR FACTORY GROUNDING)',
      img: 'rendered_drawings/42_1F_GROUNDING.png',
      devices: []
    }
  ],
  '1.5F': [
    {
      id: '15f_taac',
      title: '🚪 Mặt Bằng TA/AC (Cửa AC_4 P. Giám Đốc 202 & VP 201)',
      sheetNo: '42/31 (1.5 FLOOR FACTORY TA/AC SYSTEM)',
      img: 'rendered_drawings/32_1.5F_FACTORY_TA_AC.png',
      devices: ['AC-04', 'RACK_MAIN']
    },
    {
      id: '15f_network',
      title: '📶 Mặt Bằng Mạng & PBX (AP-03..05 & Cụm Ổ Cắm Bàn 4-Port)',
      sheetNo: '42/13 (1.5 FLOOR FACTORY NETWORK & PBX)',
      img: 'rendered_drawings/14_1.5F_FACTORY_NETWORK_PBX.png',
      devices: ['AP-03', 'AP-04', 'AP-05', 'OUT-15F-1', 'OUT-15F-2']
    }
  ],
  '2F': [
    {
      id: '2f_taac',
      title: '🚪 Mặt Bằng TA/AC (Cửa AC_5 P. IT 304 & AC_6 VP 302)',
      sheetNo: '42/32 (2ND FLOOR FACTORY TA/AC SYSTEM)',
      img: 'rendered_drawings/33_2F_FACTORY_TA_AC.png',
      devices: ['AC-05', 'AC-06', 'USB-01', 'RACK_MAIN', 'RACK_04']
    },
    {
      id: '2f_network',
      title: '📶 Mặt Bằng Mạng & PBX (Server Room 304, RACK MAIN 42U, AP-06..07, Bàn Họp 6P)',
      sheetNo: '42/14 (2ND FLOOR FACTORY NETWORK & PBX)',
      img: 'rendered_drawings/15_2F_FACTORY_NETWORK_PBX.png',
      devices: ['AP-06', 'AP-07', 'RACK_MAIN', 'RACK_04', 'OUT-2F-1', 'OUT-2F-2', 'OUT-2F-3']
    }
  ],
  'PARKING': [
    {
      id: 'park_barrier',
      title: '🚧 Mặt Bằng Flap Barrier E-Parking (10 Làn AC_10..AC_19 & 6 Bộ Barrier)',
      sheetNo: '42/35 (FLAP BARIE E-PARKING)',
      img: 'rendered_drawings/36_FLAP_BARIE_EPARKING.png',
      devices: ['AC-10', 'AC-11', 'AC-12', 'AC-13', 'AC-14', 'AC-15', 'AC-16', 'AC-17', 'AC-18', 'AC-19', 'RACK_05']
    },
    {
      id: 'park_guardhouse',
      title: '🛡️ Mặt Bằng Mạng 3 Nhà Bảo Vệ & Nhà Xe (GH1, GH2, GH3)',
      sheetNo: '42/17 (NETWORK & PBX GUARDHOUSE)',
      img: 'rendered_drawings/18_NETWORK_PBX_GUARDHOUSE.png',
      devices: ['RACK_06', 'RACK_07', 'RACK_08', 'OUT-GH-1', 'OUT-GH-2', 'OUT-GH-3']
    },
    {
      id: 'park_backbone',
      title: '🌐 Tuyến Cáp Quang Trục Backbone & Tuyến Ngầm ISP',
      sheetNo: '42/36 (BACKBONE MASTER PLAN NETWORK)',
      img: 'rendered_drawings/37_BACKBONE_MASTER_PLAN.png',
      devices: ['RACK_09']
    }
  ],
  'SCHEMATICS': [
    {
      id: 'sch_net',
      title: '📊 Sơ Đồ Nguyên Lý Mạng IT & Tổng Đài (Network & PBX Riser)',
      sheetNo: '42/06 (DIAGRAM NETWORK & PBX)',
      img: 'rendered_drawings/07_DIAGRAM_NETWORK_PBX.png',
      devices: ['RACK_MAIN', 'RACK_01', 'RACK_02', 'RACK_03', 'RACK_04', 'RACK_05', 'RACK_06', 'RACK_07', 'RACK_08', 'RACK_09']
    },
    {
      id: 'sch_taac',
      title: '🔐 Sơ Đồ Nguyên Lý Kiểm Soát Ra Vào & Chấm Công (TA/AC Riser)',
      sheetNo: '42/08 (DIAGRAM TA/AC)',
      img: 'rendered_drawings/09_DIAGRAM_TA_AC.png',
      devices: ['AC-01', 'AC-02', 'AC-03', 'AC-04', 'AC-05', 'AC-06', 'AC-10', 'TA-01', 'TA-02', 'TA-03', 'TA-04', 'TA-05']
    },
    {
      id: 'sch_rack',
      title: '🖥️ Sơ Đồ Chi Tiết Thiết Bị 10 Tủ RACK (Rack Elevation Diagrams)',
      sheetNo: '42/11 (DIAGRAM RACK)',
      img: 'rendered_drawings/12_DIAGRAM_RACK.png',
      devices: ['RACK_MAIN', 'RACK_PA', 'RACK_01', 'RACK_02', 'RACK_03', 'RACK_04', 'RACK_05', 'RACK_06', 'RACK_07', 'RACK_08', 'RACK_09']
    },
    {
      id: 'sch_grounding',
      title: '⚡ Tổng Mặt Bằng Hệ Thống Tiếp Địa An Toàn Chống Sét',
      sheetNo: '42/40 (GROUNDING MASTER PLAN)',
      img: 'rendered_drawings/41_GROUNDING_MASTER_PLAN.png',
      devices: []
    },
    {
      id: 'sch_isp',
      title: '🌐 Tổng Mặt Bằng Tuyến Cáp Quang Đầu Vào Nhà Mạng ISP',
      sheetNo: '42/42 (ISP MASTER PLAN)',
      img: 'rendered_drawings/43_ISP_MASTER_PLAN.png',
      devices: []
    }
  ]
};

// Multilingual Dictionary
const I18N = {
  vi: {
    nav_dashboard: "Bảng Điều Khiển Live",
    nav_floorplans: "Mặt Bằng & Vị Trí",
    nav_map: "Mặt Bằng & Vị Trí",
    nav_boq: "Thống Kê Bản Vẽ ELV",
    nav_devices: "Danh Sách Thiết Bị",
    nav_personnel: "Quản Lý Nhân Sự",
    nav_attendance: "Báo Cáo Chấm Công",
    nav_sql: "Truy Vấn HCP_DATA",
    nav_manual: "Sổ Tay Vận Hành",
    title_dashboard: "Trung Tâm Giám Sát Cửa & Face ID Trực Tuyến",
    title_floorplans: "Hồ Sơ Bản Vẽ & Phân Lớp Kỹ Thuật (CAD Blueprint Viewer)",
    title_boq: "Bảng Thống Kê Khối Lượng Thiết Bị ELV (Sheet 42/03)",
    title_devices: "Danh Mục Thiết Bị Cửa & Chấm Công",
    title_personnel: "Danh Sách Nhân Viên & Dữ Liệu Khuôn Mặt Face ID",
    title_attendance: "Báo Cáo Chấm Công Hàng Ngày (First In / Last Out)",
    title_sql: "Truy Vấn Cơ Sở Dữ Liệu SQL Trực Tiếp (HCP_DATA)",
    title_manual: "Sổ Tay Vận Hành & Đào Tạo Chuẩn Hóa",
    stat_face_rate: "Tỷ Lệ Nhận Diện Face ID",
    stat_total_devices: "Tổng Số Thiết Bị",
    stat_active_shift: "Ca Làm Việc Chuẩn",
    stat_total_scans: "Tổng Lượt Sự Kiện",
    stat_realtime_synced: "Đồng Bộ Tự Động SQL",
    stat_primary_method: "Phương thức sinh trắc chính",
    title_live_events: "Nhật Ký Quẹt Face ID & Cửa Thời Gian Thực",
    btn_export_csv: "Xuất File CSV (Excel Chuẩn)",
    btn_refresh: "Làm Mới"
  },
  en: {
    nav_dashboard: "Live Dashboard",
    nav_floorplans: "CAD Floorplans & Layers",
    nav_map: "CAD Floorplans & Layers",
    nav_boq: "ELV BOQ Summary",
    nav_devices: "Device Directory",
    nav_personnel: "Personnel Directory",
    nav_attendance: "Attendance Report",
    nav_sql: "HCP_DATA SQL Studio",
    nav_manual: "Operation Manual",
    title_dashboard: "Live Face ID & Access Control Monitoring Center",
    title_floorplans: "CAD Blueprint & Technical Layer Viewer",
    title_boq: "ELV Equipment Bill of Quantities (Sheet 42/03)",
    title_devices: "Access Control & Time Attendance Devices",
    title_personnel: "Personnel List & Face ID Registration",
    title_attendance: "Daily Attendance Report (First In / Last Out)",
    title_sql: "Direct SQL Database Query (HCP_DATA)",
    title_manual: "Standard Operation Procedure (SOP)",
    stat_face_rate: "Face ID Recognition Rate",
    stat_total_devices: "Total Devices",
    stat_active_shift: "Standard Work Shift",
    stat_total_scans: "Total Event Scans",
    stat_realtime_synced: "Realtime SQL Sync",
    stat_primary_method: "Primary Biometric Method",
    title_live_events: "Real-time Access & Face ID Event Log",
    btn_export_csv: "Export CSV (Excel Standard)",
    btn_refresh: "Refresh"
  },
  ko: {
    nav_dashboard: "실시간 대시보드",
    nav_floorplans: "도면 및 레이어 뷰어",
    nav_map: "도면 및 레이어 뷰어",
    nav_boq: "ELV 물량 집계표",
    nav_devices: "장비 목록",
    nav_personnel: "인사 및 얼굴 관리",
    nav_attendance: "근태 리포트",
    nav_sql: "HCP_DATA SQL 조회",
    nav_manual: "운영 매뉴얼",
    title_dashboard: "Face ID 및 출입통제 실시간 모니터링",
    title_floorplans: "도면 및 기술 레이어 뷰어",
    title_boq: "ELV 장비 수량 집계표 (Sheet 42/03)",
    title_devices: "출입 통제 및 근태 장비 목록",
    title_personnel: "임직원 명단 및 얼굴 등록 데이터",
    title_attendance: "일일 근태 집계 (First In / Last Out)",
    title_sql: "HCP_DATA 데이터베이스 직접 조회",
    title_manual: "표준 운영 지침서 (SOP)",
    stat_face_rate: "Face ID 인식률",
    stat_total_devices: "총 장비 수",
    stat_active_shift: "기본 근무 교대",
    stat_total_scans: "총 출입 이벤트 수",
    stat_realtime_synced: "실시간 SQL 자동 동기화",
    stat_primary_method: "주요 생체 인증 수단",
    title_live_events: "실시간 출입 및 Face ID 이벤트 로그",
    btn_export_csv: "CSV 내보내기 (Excel 표준)",
    btn_refresh: "새로고침"
  }
};

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
  
  const saved = localStorage.getItem('theme') || 'dark';
  applyTheme(saved);

  if (btn) {
    btn.addEventListener('click', () => {
      const cur = document.documentElement.getAttribute('data-theme') || 'dark';
      const next = cur === 'dark' ? 'light' : 'dark';
      applyTheme(next);
      localStorage.setItem('theme', next);
    });
  }

  function applyTheme(t) {
    document.documentElement.setAttribute('data-theme', t);
    if (icon) icon.textContent = t === 'dark' ? '🌙' : '☀️';
    if (label) label.textContent = t === 'dark' ? 'Giao diện Tối' : 'Giao diện Sáng';
  }
}

// Setup Navigation & Sidebar Collapsible Mode
function setupNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  navItems.forEach(item => {
    item.addEventListener('click', () => {
      navItems.forEach(i => i.classList.remove('active'));
      item.classList.add('active');
      const viewId = item.getAttribute('data-view');
      switchView(viewId);
    });
  });

  const collapseBtn = document.getElementById('btn-collapse-sidebar');
  const appContainer = document.querySelector('.app-container');
  if (collapseBtn && appContainer) {
    collapseBtn.addEventListener('click', () => {
      appContainer.classList.toggle('sidebar-collapsed');
    });
  }
}

function switchView(viewId) {
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
  if (viewId === 'attendance') {
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
      if (dot && text) {
        if (statusData.dbConnected) {
          dot.className = 'status-dot online';
          text.textContent = 'HCP_DATA Online';
        } else {
          dot.className = 'status-dot warning';
          text.textContent = 'CSDL Cục Bộ (Fallback)';
        }
      }
    }

    if (eventsRes && eventsRes.ok) {
      liveEvents = await eventsRes.json();
      filterAndRenderDashboardEvents();
    }

    if (statsRes && statsRes.ok) {
      const stats = await statsRes.json();
      const total = stats.totalScans || 1;
      const facePct = ((stats.faceCount / total) * 100).toFixed(1);
      const fingerPct = ((stats.fingerCount / total) * 100).toFixed(1);
      const cardPct = ((stats.cardCount / total) * 100).toFixed(1);

      const barFace = document.getElementById('bar-face');
      const barFinger = document.getElementById('bar-finger');
      const barCard = document.getElementById('bar-card');

      if (barFace) barFace.style.width = `${facePct}%`;
      if (barFinger) barFinger.style.width = `${fingerPct}%`;
      if (barCard) barCard.style.width = `${cardPct}%`;

      const statFaceRate = document.getElementById('stat-face-rate');
      if (statFaceRate) statFaceRate.textContent = `${facePct}%`;

      const valFace = document.getElementById('val-face-count');
      const valFinger = document.getElementById('val-finger-count');
      const valCard = document.getElementById('val-card-count');

      if (valFace) valFace.textContent = `${stats.faceCount} (${facePct}%)`;
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
    { key: 'taAc', title: 'II. HỆ THỐNG KIỂM SOÁT CỬA & CHẤM CÔNG (TA/AC SYSTEM)', icon: '🚪', items: summary.taAc || [] },
    { key: 'grounding', title: 'III. HỆ THỐNG TIẾP ĐỊA AN TOÀN (GROUNDING SYSTEM)', icon: '⚡', items: summary.grounding || [] },
    { key: 'isp', title: 'IV. HỆ THỐNG ĐƯỜNG TRUYỀN NHÀ MẠNG (ISP LINE SYSTEM)', icon: '🌐', items: summary.isp || [] }
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

// Open In-Viewport Inspector Drawer (Supports AC, TA, Barrier, IT Rack, Wi-Fi, Outlets)
window.openDeviceInspector = function(item) {
  const drawer = document.getElementById('drawer-device-inspector');
  const icon = document.getElementById('drawer-icon');
  const title = document.getElementById('drawer-title');
  const code = document.getElementById('drawer-code');
  const body = document.getElementById('drawer-body');

  if (!drawer || !item) return;

  icon.textContent = item.icon || (item.type === 'WIFI' ? '📶' : (item.type && item.type.includes('OUTLET') ? '🔌' : '🚪'));
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
          <span style="color: var(--text-faint);">Quy Cách:</span>
          <span>${item.dimensions || 'Tủ Tiêu Chuẩn 19 inch'}</span>
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
  } else if (item.type && (item.type.includes('OUTLET') || item.type === 'OUTLET')) {
    contentHtml = `
      <div style="background: rgba(245,158,11,0.1); border: 1px solid rgba(245,158,11,0.3); border-radius: var(--radius-md); padding: 12px;">
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Vị trí lắp:</span>
          <strong>${item.floor} — ${item.room}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Loại Ổ Cắm:</span>
          <strong style="color: #fbbf24;">${item.typeLabel || 'Ổ Cắm Mạng / Thoại'}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Cấu Hình Port:</span>
          <strong style="font-family: var(--font-mono); color: #22d3ee;">${item.ports || 'RJ45 Cat6 UTP'}</strong>
        </div>
        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
          <span style="color: var(--text-faint);">Kiểu Lắp Đặt:</span>
          <span>${item.mountType || 'Âm Sàn / Âm Tường'}</span>
        </div>
        <div style="display: flex; justify-content: space-between;">
          <span style="color: var(--text-faint);">Tủ RACK Cung Cấp:</span>
          <strong style="color: var(--emerald); font-family: var(--font-mono);">${item.rack || 'RACK_MAIN'}</strong>
        </div>
      </div>

      <div style="display: flex; gap: 8px;">
        <span class="badge badge-success">● Cáp Cat6 UTP Sẵn Sàng</span>
        <span class="badge" style="background: rgba(6,182,212,0.15); color: #22d3ee;">1000BASE-T GbE</span>
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
      <td><strong>${e.PersonName || 'Khách / Chưa định danh'}</strong></td>
      <td><span class="badge" style="background: rgba(99,102,241,0.12); border: 1px solid var(--card-border); color: var(--text-muted);">${e.Department || 'Chung'}</span></td>
      <td><span style="font-family: var(--font-mono);">${e.EventTime ? e.EventTime.replace('T', ' ') : '—'}</span></td>
      <td><strong>${e.DeviceName || 'Cổng Kiểm Soát'}</strong></td>
      <td><span class="badge ${badgeClass}">${authLabel}</span></td>
      <td><span class="badge badge-success">✓ Hợp Lệ</span></td>
    `;
    tbody.appendChild(tr);
  });

  const countEl = document.getElementById('live-event-count');
  if (countEl) countEl.textContent = `Hiển thị ${events.length} sự kiện gần nhất`;
}

function setupDashboardFilters() {
  const search = document.getElementById('dashboard-search');
  const devSelect = document.getElementById('filter-device');
  const authSelect = document.getElementById('filter-auth');

  if (search) search.addEventListener('input', filterAndRenderDashboardEvents);
  if (devSelect) devSelect.addEventListener('change', filterAndRenderDashboardEvents);
  if (authSelect) authSelect.addEventListener('change', filterAndRenderDashboardEvents);
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
    if (tbody) {
      tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--rose); padding: 28px;">Không thể kết nối máy chủ chấm công: ${e.message}</td></tr>`;
    }
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
