/**
 * VINATECH HƯNG YÊN — SMART FACTORY 3D DIGITAL TWIN & ELV MASTER ENGINE
 * Full 5 ELV Systems: TA/AC, CCTV (81 Cam), Wi-Fi & IT Network, PA Sound (96 Spk), 10 RACKs & Cable Trays
 * Based on: Drawing_ELV System_VINATECH_260615_v5.2.pdf (Sheet 42/01 - 42/42)
 */

class Factory3DEngine {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    if (!this.container) {
      console.error(`Container #${containerId} not found`);
      return;
    }

    this.options = Object.assign({
      theme: 'dark',
      onDeviceClick: null,
      onDeviceHover: null
    }, options);

    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.controls = null;
    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();

    // Scene Architecture Hierarchy
    this.groups = {
      ground: new THREE.Group(),
      cableTrays: new THREE.Group(),
      floor1: new THREE.Group(),
      floor1_5: new THREE.Group(),
      floor2: new THREE.Group(),
      parking: new THREE.Group(),
      roof: new THREE.Group(),
      racks: new THREE.Group(),
      cameras: new THREE.Group(),
      wifi: new THREE.Group(),
      pa: new THREE.Group(),
      beacons: new THREE.Group(),
      roomTags: new THREE.Group(),
      effects: new THREE.Group()
    };

    this.allDevices = new Map(); // id -> { group, data, pos3D, type, tagSprite, mesh }
    this.pulsingObjects = [];
    this.activeFloor = 'ALL';
    this.activeLayer = 'ALL';
    this.isExploded = false;
    this.isXRay = true;
    this.isAutoRotate = false;
    this.animationId = null;
    this.clock = new THREE.Clock();

    this.defaultCameraPos = new THREE.Vector3(150, 120, 170);
    this.targetLookAt = new THREE.Vector3(10, 5, 0);

    this.init();
  }

  init() {
    this.initScene();
    this.initLights();
    this.buildCampusGround();
    this.buildFloor1();
    this.buildFloor1_5();
    this.buildFloor2();
    this.buildParkingAndGates();
    this.buildRoof();
    this.buildCableTrayTrunking();
    this.setupInteractions();
    this.animate();

    window.addEventListener('resize', () => this.onWindowResize());
  }

  initScene() {
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x070b14);
    this.scene.fog = new THREE.FogExp2(0x070b14, 0.002);

    const width = this.container.clientWidth || 900;
    const height = this.container.clientHeight || 680;

    this.camera = new THREE.PerspectiveCamera(40, width / height, 1, 1500);
    this.camera.position.copy(this.defaultCameraPos);

    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: false,
      powerPreference: 'high-performance',
      precision: 'mediump'
    });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.2;

    this.container.innerHTML = '';
    this.container.appendChild(this.renderer.domElement);

    if (typeof THREE.OrbitControls !== 'undefined') {
      this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      this.controls.enableDamping = true;
      this.controls.dampingFactor = 0.08;
      this.controls.maxPolarAngle = Math.PI / 2 - 0.02;
      this.controls.minDistance = 20;
      this.controls.maxDistance = 550;
      this.controls.target.copy(this.targetLookAt);
    }

    // Add root groups
    Object.values(this.groups).forEach(g => this.scene.add(g));
  }

  initLights() {
    const ambientLight = new THREE.AmbientLight(0xdce7ff, 0.95);
    this.scene.add(ambientLight);

    const dirLight = new THREE.DirectionalLight(0xffffff, 1.15);
    dirLight.position.set(120, 180, 90);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.width = 1024;
    dirLight.shadow.mapSize.height = 1024;
    dirLight.shadow.camera.near = 10;
    dirLight.shadow.camera.far = 450;
    const d = 130;
    dirLight.shadow.camera.left = -d;
    dirLight.shadow.camera.right = d;
    dirLight.shadow.camera.top = d;
    dirLight.shadow.camera.bottom = -d;
    this.scene.add(dirLight);

    // Accent Lights
    const itLight = new THREE.PointLight(0x10b981, 2.5, 80);
    itLight.position.set(45, 30, -25);
    this.scene.add(itLight);

    const officeLight = new THREE.PointLight(0x6366f1, 2.0, 90);
    officeLight.position.set(73, 30, -10);
    this.scene.add(officeLight);

    const prodLight = new THREE.PointLight(0x06b6d4, 2.2, 110);
    prodLight.position.set(0, 20, -10);
    this.scene.add(prodLight);

    const whLight = new THREE.PointLight(0xf59e0b, 1.8, 80);
    whLight.position.set(-55, 18, -10);
    this.scene.add(whLight);

    const parkLight = new THREE.PointLight(0x38bdf8, 2.0, 90);
    parkLight.position.set(-25, 15, 72);
    this.scene.add(parkLight);
  }

  // Set Theme (Light / Dark) for 3D Viewport
  setTheme(theme) {
    this.options.theme = theme;
    const isLight = theme === 'light';
    const bgColor = isLight ? 0xe2e8f0 : 0x070b14;

    if (this.scene) {
      this.scene.background.setHex(bgColor);
      if (this.scene.fog) {
        this.scene.fog.color.setHex(bgColor);
      }
    }

    if (this.groundMesh && this.groundMesh.material) {
      this.groundMesh.material.color.setHex(isLight ? 0xcbd5e1 : 0x0a0f1d);
    }
  }

  // Ground & Roads
  buildCampusGround() {
    const isLight = (document.documentElement.getAttribute('data-theme') === 'light');
    const groundGeo = new THREE.PlaneGeometry(550, 550);
    const groundMat = new THREE.MeshStandardMaterial({ color: isLight ? 0xcbd5e1 : 0x0a0f1d, roughness: 0.85, metalness: 0.2 });
    const ground = new THREE.Mesh(groundGeo, groundMat);
    ground.rotation.x = -Math.PI / 2;
    ground.position.y = -0.4;
    ground.receiveShadow = true;
    this.groundMesh = ground;
    this.groups.ground.add(ground);

    const grid = new THREE.GridHelper(450, 90, 0x4338ca, 0x1e293b);
    grid.position.y = -0.2;
    this.groups.ground.add(grid);

    const padGeo = new THREE.BoxGeometry(192, 1.0, 122);
    const padMat = new THREE.MeshStandardMaterial({ color: 0x111c2e, roughness: 0.5, metalness: 0.4 });
    const pad = new THREE.Mesh(padGeo, padMat);
    pad.position.set(5, 0, -5);
    pad.receiveShadow = true;
    this.groups.ground.add(pad);

    const roadMat = new THREE.MeshStandardMaterial({ color: 0x182234, roughness: 0.8 });
    const roadGeo = new THREE.BoxGeometry(220, 0.4, 150);
    const road = new THREE.Mesh(roadGeo, roadMat);
    road.position.set(5, -0.3, 0);
    road.receiveShadow = true;
    this.groups.ground.add(road);

    const parkPadGeo = new THREE.BoxGeometry(116, 0.8, 48);
    const parkPadMat = new THREE.MeshStandardMaterial({ color: 0x0f172a, roughness: 0.6, metalness: 0.4 });
    const parkPad = new THREE.Mesh(parkPadGeo, parkPadMat);
    parkPad.position.set(-25, 0, 72);
    parkPad.receiveShadow = true;
    this.groups.ground.add(parkPad);

    const laneMat = new THREE.MeshBasicMaterial({ color: 0x38bdf8 });
    for (let i = -5; i <= 5; i++) {
      const lineGeo = new THREE.PlaneGeometry(1.2, 30);
      const line = new THREE.Mesh(lineGeo, laneMat);
      line.rotation.x = -Math.PI / 2;
      line.position.set(-25 + i * 9.5, 0.42, 72);
      this.groups.ground.add(line);
    }
  }

  // Room Builder
  createRoom({ name, labelTag, x, z, width, depth, height, color, floorColor, group, floorLevel = 0, isProduction = false }) {
    const yBase = floorLevel;

    const floorGeo = new THREE.BoxGeometry(width - 0.4, 0.4, depth - 0.4);
    const floorMat = new THREE.MeshStandardMaterial({ color: floorColor || 0x1e293b, roughness: 0.3, metalness: 0.5 });
    const floorMesh = new THREE.Mesh(floorGeo, floorMat);
    floorMesh.position.set(x, yBase + 0.2, z);
    floorMesh.receiveShadow = true;
    group.add(floorMesh);

    const wallMat = new THREE.MeshPhysicalMaterial({
      color: color || 0x38bdf8,
      transparent: true,
      opacity: this.isXRay ? 0.32 : 0.85,
      roughness: 0.1,
      metalness: 0.15,
      transmission: this.isXRay ? 0.68 : 0.15,
      ior: 1.2
    });

    const wallGeo = new THREE.BoxGeometry(width, height, depth);
    const wallMesh = new THREE.Mesh(wallGeo, wallMat);
    wallMesh.position.set(x, yBase + height / 2, z);
    wallMesh.castShadow = true;
    wallMesh.receiveShadow = true;
    group.add(wallMesh);

    const edges = new THREE.EdgesGeometry(wallGeo);
    const lineMat = new THREE.LineBasicMaterial({ color: color || 0x60a5fa, linewidth: 1.5, transparent: true, opacity: 0.8 });
    const wireframe = new THREE.LineSegments(edges, lineMat);
    wireframe.position.copy(wallMesh.position);
    group.add(wireframe);

    if (labelTag) {
      const tagSprite = this.createFloatingTextSprite(labelTag, color || 0x38bdf8);
      tagSprite.position.set(x, yBase + height + 3.5, z);
      this.groups.roomTags.add(tagSprite);
    }

    if (isProduction) {
      this.addMachineryBlocks(group, x, yBase, z, width, depth);
    }

    return { wallMesh, wireframe };
  }

  createFloatingTextSprite(text, colorHex) {
    if (!text) text = '';

    // Dynamic text measurement for zero clipping on long titles (Guardhouses, Substation, etc.)
    const measureCanvas = document.createElement('canvas');
    const mCtx = measureCanvas.getContext('2d');

    let fontSize = 32;
    if (text.length > 25) fontSize = 26;
    if (text.length > 36) fontSize = 21;

    mCtx.font = `bold ${fontSize}px "Plus Jakarta Sans", -apple-system, sans-serif`;
    const textWidth = mCtx.measureText(text).width;

    const padX = 36;
    const canvasWidth = Math.max(260, Math.ceil(textWidth + padX * 2));
    const canvasHeight = 100;

    const canvas = document.createElement('canvas');
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;
    const ctx = canvas.getContext('2d');

    const strokeCol = typeof colorHex === 'number' ? '#' + colorHex.toString(16).padStart(6, '0') : (colorHex || '#6366f1');
    ctx.fillStyle = 'rgba(15, 23, 42, 0.94)';
    ctx.strokeStyle = strokeCol;
    ctx.lineWidth = 5;

    const r = 24;
    ctx.beginPath();
    ctx.moveTo(r, 6);
    ctx.lineTo(canvasWidth - r, 6);
    ctx.quadraticCurveTo(canvasWidth, 6, canvasWidth, 6 + r);
    ctx.lineTo(canvasWidth, canvasHeight - 6 - r);
    ctx.quadraticCurveTo(canvasWidth, canvasHeight - 6, canvasWidth - r, canvasHeight - 6);
    ctx.lineTo(r, canvasHeight - 6);
    ctx.quadraticCurveTo(0, canvasHeight - 6, 0, canvasHeight - 6 - r);
    ctx.lineTo(0, 6 + r);
    ctx.quadraticCurveTo(0, 6, r, 6);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = `bold ${fontSize}px "Plus Jakarta Sans", -apple-system, sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(text, canvasWidth / 2, canvasHeight / 2 + 1);

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    const spriteMat = new THREE.SpriteMaterial({ map: texture, transparent: true, depthTest: false });
    const sprite = new THREE.Sprite(spriteMat);

    // Scale proportionally to maintain natural aspect ratio without distortion
    const baseH = 3.6;
    const baseW = baseH * (canvasWidth / canvasHeight);
    sprite.scale.set(baseW, baseH, 1);
    return sprite;
  }

  addMachineryBlocks(group, cx, cy, cz, w, d) {
    const machMat = new THREE.MeshStandardMaterial({ color: 0x334155, metalness: 0.8, roughness: 0.3 });
    const accentMat = new THREE.MeshStandardMaterial({ color: 0x06b6d4, emissive: 0x083344, roughness: 0.2 });

    for (let r = 0; r < 3; r++) {
      for (let c = 0; c < 2; c++) {
        const mx = cx - w / 3 + c * (w / 2.2);
        const mz = cz - d / 3 + r * (d / 3.2);

        const mGeo = new THREE.BoxGeometry(10, 4.5, 6);
        const machine = new THREE.Mesh(mGeo, machMat);
        machine.position.set(mx, cy + 2.25, mz);
        machine.castShadow = true;
        group.add(machine);

        const indGeo = new THREE.BoxGeometry(9.6, 0.4, 0.4);
        const ind = new THREE.Mesh(indGeo, accentMat);
        ind.position.set(mx, cy + 4.2, mz + 2.9);
        group.add(ind);
      }
    }
  }

  // TẦNG 1 NHÀ XƯỞNG
  buildFloor1() {
    const g = this.groups.floor1;
    const h = 13;

    this.createRoom({
      name: "Kho 1 & Dock",
      labelTag: "📦 Kho 104 & Dock 105",
      x: -55, z: -10, width: 44, depth: 75, height: h,
      color: 0xf59e0b, floorColor: 0x292524,
      group: g, floorLevel: 0
    });

    this.createRoom({
      name: "Xưởng Sản Xuất Chính",
      labelTag: "⚡ Xưởng Sản Xuất Supercapacitor",
      x: 0, z: -10, width: 62, depth: 75, height: h,
      color: 0x06b6d4, floorColor: 0x0f2338,
      group: g, floorLevel: 0, isProduction: true
    });

    this.createRoom({
      name: "P. Điều Khiển 128",
      labelTag: "🎛️ P. Điều Khiển 128",
      x: 46, z: -32, width: 28, depth: 30, height: h,
      color: 0x8b5cf6, floorColor: 0x1e1b4b,
      group: g, floorLevel: 0
    });

    this.createRoom({
      name: "P. Trực PCCC / EPS",
      labelTag: "🧯 PCCC 151 / EPS",
      x: 74, z: -32, width: 24, depth: 30, height: h,
      color: 0xef4444, floorColor: 0x3f1212,
      group: g, floorLevel: 0
    });

    this.createRoom({
      name: "Căn Tin 115A",
      labelTag: "🍽️ Căn Tin 115A & Locker",
      x: 46, z: 8, width: 28, depth: 36, height: h,
      color: 0x10b981, floorColor: 0x064e3b,
      group: g, floorLevel: 0
    });

    this.createRoom({
      name: "Sảnh Chính & Showroom",
      labelTag: "🏛️ Sảnh Chính & Showroom 101",
      x: 74, z: 8, width: 24, depth: 36, height: h,
      color: 0x6366f1, floorColor: 0x1e1b4b,
      group: g, floorLevel: 0
    });

    // === KHU PHỤ TRỢ SẢN XUẤT — BẢN VẼ ELV v5.2 ===

    // Khu Pha Trộn Mixer / Slurry (bên trong xưởng SX)
    this.createRoom({
      name: "Khu Pha Trộn Mixer",
      labelTag: "🔬 Mixer/Slurry",
      x: -5, z: -42, width: 28, depth: 14, height: h,
      color: 0x0891b2, floorColor: 0x164e63,
      group: g, floorLevel: 0
    });

    // Khu Sấy & Cuộn Electrode (Drying/Winding)
    this.createRoom({
      name: "Khu Sấy & Cuộn",
      labelTag: "🌀 Drying/Winding",
      x: 22, z: -42, width: 24, depth: 14, height: h,
      color: 0x0e7490, floorColor: 0x155e75,
      group: g, floorLevel: 0
    });

    // P.136 Locker Nữ & QC Room
    this.createRoom({
      name: "P.136 Locker & QC",
      labelTag: "🧪 P.136 QC/Locker",
      x: 30, z: 16, width: 14, depth: 16, height: h,
      color: 0x14b8a6, floorColor: 0x134e4a,
      group: g, floorLevel: 0
    });

    // Khu Đóng Gói & Kiểm Tra (Packing/Testing)
    this.createRoom({
      name: "Khu Đóng Gói",
      labelTag: "📦 Packing/Testing",
      x: -30, z: 16, width: 20, depth: 16, height: h,
      color: 0x0284c7, floorColor: 0x0c4a6e,
      group: g, floorLevel: 0
    });

    // Hành Lang Kỹ Thuật (Technical Corridor)
    this.createRoom({
      name: "Hành Lang Kỹ Thuật",
      labelTag: "🔧 Hành Lang KT",
      x: 33, z: -10, width: 4, depth: 55, height: h,
      color: 0x475569, floorColor: 0x1e293b,
      group: g, floorLevel: 0
    });

    // P. Nghỉ Ca Nam/Nữ
    this.createRoom({
      name: "P. Nghỉ Ca",
      labelTag: "😴 P.Nghỉ Ca",
      x: 46, z: 24, width: 28, depth: 12, height: h,
      color: 0x059669, floorColor: 0x065f46,
      group: g, floorLevel: 0
    });

    // WC Tầng 1
    this.createRoom({
      name: "WC Tầng 1",
      labelTag: "🚻 WC 137",
      x: 74, z: -5, width: 12, depth: 10, height: h,
      color: 0x64748b, floorColor: 0x334155,
      group: g, floorLevel: 0
    });
  }

  // TẦNG 1.5 NHÀ XƯỞNG
  buildFloor1_5() {
    const g = this.groups.floor1_5;
    const h = 9;
    const yBase = 14;

    this.createRoom({
      name: "Văn Phòng 1.5F",
      labelTag: "🏢 Văn Phòng 1.5F (P. 201/202)",
      x: 60, z: -10, width: 50, depth: 72, height: h,
      color: 0xa855f7, floorColor: 0x2e1065,
      group: g, floorLevel: yBase
    });

    // P. Giám Đốc 202 (bên trong VP 1.5F)
    this.createRoom({
      name: "P. Giám Đốc 202",
      labelTag: "👤 P.GĐ 202",
      x: 78, z: -25, width: 16, depth: 22, height: h,
      color: 0x9333ea, floorColor: 0x3b0764,
      group: g, floorLevel: yBase
    });

    // P. Họp Nhỏ 1.5F
    this.createRoom({
      name: "P. Họp Nhỏ 1.5F",
      labelTag: "💬 P.Họp 1.5F",
      x: 78, z: 10, width: 16, depth: 20, height: h,
      color: 0x7c3aed, floorColor: 0x4c1d95,
      group: g, floorLevel: yBase
    });
  }

  // TẦNG 2 NHÀ XƯỞNG
  buildFloor2() {
    const g = this.groups.floor2;
    const h = 12;
    const yBase = 24;

    this.createRoom({
      name: "Phòng IT & Server 304",
      labelTag: "💻 IT Server 304 [RACK_MAIN 42U + PA 27U]",
      x: 45, z: -25, width: 26, depth: 40, height: h,
      color: 0x10b981, floorColor: 0x064e3b,
      group: g, floorLevel: yBase
    });

    this.createRoom({
      name: "Văn Phòng Chính Tầng 2 (302)",
      labelTag: "👔 Khối Văn Phòng 2F (302 & 303)",
      x: 73, z: -10, width: 28, depth: 70, height: h,
      color: 0x6366f1, floorColor: 0x1e1b4b,
      group: g, floorLevel: yBase
    });

    this.createRoom({
      name: "Phòng Họp Lớn 2F",
      labelTag: "🤝 Phòng Họp Lớn 2F",
      x: 45, z: 12, width: 26, depth: 32, height: h,
      color: 0x06b6d4, floorColor: 0x083344,
      group: g, floorLevel: yBase
    });

    // P. Giám Đốc 303
    this.createRoom({
      name: "P. Giám Đốc 303",
      labelTag: "👤 P.GĐ 303",
      x: 86, z: -25, width: 14, depth: 18, height: h,
      color: 0x4f46e5, floorColor: 0x312e81,
      group: g, floorLevel: yBase
    });

    // P. Họp Nhỏ 2F
    this.createRoom({
      name: "P. Họp Nhỏ 2F",
      labelTag: "💬 P.Họp Nhỏ",
      x: 45, z: 28, width: 14, depth: 10, height: h,
      color: 0x0284c7, floorColor: 0x0c4a6e,
      group: g, floorLevel: yBase
    });

    // Pantry & Break Room
    this.createRoom({
      name: "Pantry 2F",
      labelTag: "☕ Pantry",
      x: 60, z: 28, width: 14, depth: 10, height: h,
      color: 0xf59e0b, floorColor: 0x78350f,
      group: g, floorLevel: yBase
    });

    // WC Tầng 2
    this.createRoom({
      name: "WC 2F",
      labelTag: "🚻 WC 2F",
      x: 86, z: 10, width: 10, depth: 16, height: h,
      color: 0x64748b, floorColor: 0x334155,
      group: g, floorLevel: yBase
    });
  }

  // TOÀN BỘ KHUÔN VIÊN & 3 NHÀ BẢO VỆ + KHU TIỆN ÍCH PHỤ TRỢ (GUARDHOUSES & CAMPUS FACILITIES)
  buildParkingAndGates() {
    const g = this.groups.parking;

    // 1. NHÀ BẢO VỆ 1 — CỔNG CHÍNH (GUARDHOUSE 1 - MAIN GATE [RACK_06])
    this.createRoom({
      name: "Nhà Bảo Vệ 1",
      labelTag: "🛡️ Nhà Bảo Vệ 1 [Cổng Chính - RACK_06]",
      x: 55, z: 78, width: 16, depth: 16, height: 7,
      color: 0xf59e0b, floorColor: 0x451a03,
      group: g, floorLevel: 0
    });

    // 2. NHÀ BẢO VỆ 2 — CỔNG PHỤ & LOGISTICS DOCK (GUARDHOUSE 2 [RACK_07])
    this.createRoom({
      name: "Nhà Bảo Vệ 2",
      labelTag: "🚛 Nhà Bảo Vệ 2 [Cổng Phụ Logistics - RACK_07]",
      x: -95, z: -10, width: 16, depth: 16, height: 7,
      color: 0xf59e0b, floorColor: 0x451a03,
      group: g, floorLevel: 0
    });

    // 3. NHÀ BẢO VỆ 3 — CỔNG NHÀ XE (GUARDHOUSE 3 [RACK_08])
    this.createRoom({
      name: "Nhà Bảo Vệ 3",
      labelTag: "🅿️ Nhà Bảo Vệ 3 [Cổng Nhà Xe - RACK_08]",
      x: -75, z: 78, width: 16, depth: 16, height: 7,
      color: 0xf59e0b, floorColor: 0x451a03,
      group: g, floorLevel: 0
    });

    // 4. TRẠM BIẾN ÁP (SUBSTATION 22kV / 0.4kV)
    this.createRoom({
      name: "Trạm Biến Áp",
      labelTag: "⚡ Trạm Biến Áp (Substation)",
      x: -95, z: 48, width: 22, depth: 18, height: 8,
      color: 0xeab308, floorColor: 0x422006,
      group: g, floorLevel: 0
    });

    // 5. KHU BỂ NƯỚC PCCC & TRẠM BƠM CỨU HỎA (PCCC WATER TANK & PUMP HOUSE)
    this.createRoom({
      name: "Bể PCCC & Trạm Bơm",
      labelTag: "🧯 Bể Nước PCCC & Bơm Cứu Hỏa",
      x: -95, z: 22, width: 22, depth: 22, height: 8,
      color: 0xef4444, floorColor: 0x450a0a,
      group: g, floorLevel: 0
    });

    // 6. KHU XỬ LÝ NƯỚC THẢI & TIỆN ÍCH (WASTE WATER TREATMENT & UTILITY)
    this.createRoom({
      name: "Trạm Xử Lý Nước Thải",
      labelTag: "♻️ Xử Lý Nước Thải & Utility",
      x: -95, z: -48, width: 22, depth: 22, height: 8,
      color: 0x06b6d4, floorColor: 0x083344,
      group: g, floorLevel: 0
    });

    // Mái che Khu Nhà Xe E-Parking
    const roofMat = new THREE.MeshStandardMaterial({ color: 0x1e293b, metalness: 0.6, roughness: 0.3, transparent: true, opacity: 0.8 });
    const canopyGeo = new THREE.BoxGeometry(85, 0.6, 32);
    const canopy = new THREE.Mesh(canopyGeo, roofMat);
    canopy.position.set(-25, 9, 78);
    canopy.castShadow = true;
    g.add(canopy);

    const pilMat = new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.8 });
    for (let px of [-55, -25, 5]) {
      for (let pz of [66, 90]) {
        const pGeo = new THREE.CylinderGeometry(0.5, 0.5, 9, 16);
        const pil = new THREE.Mesh(pGeo, pilMat);
        pil.position.set(px, 4.5, pz);
        pil.castShadow = true;
        g.add(pil);
      }
    }

    // 10 Làn Cổng Flap Barrier (5 Làn Vào + 5 Làn Ra)
    const barMat = new THREE.MeshStandardMaterial({ color: 0xe2e8f0, metalness: 0.9, roughness: 0.1 });
    const flapMat = new THREE.MeshStandardMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.75 });

    for (let i = 0; i < 10; i++) {
      const bx = -58 + i * 7.5;
      const bz = 78;

      const bGeo = new THREE.BoxGeometry(1.6, 2.6, 4.2);
      const barrier = new THREE.Mesh(bGeo, barMat);
      barrier.position.set(bx, 1.3, bz);
      barrier.castShadow = true;
      g.add(barrier);

      const fGeo = new THREE.BoxGeometry(0.2, 2.0, 1.4);
      const flap = new THREE.Mesh(fGeo, flapMat);
      flap.position.set(bx + 1.2, 1.4, bz);
      g.add(flap);
    }

    // Hàng rào chu vi & Cổng bảo vệ (Perimeter Fence & Gate Poles)
    const fenceMat = new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.7, roughness: 0.4 });
    const gatePoleGeo = new THREE.CylinderGeometry(0.8, 0.8, 8, 16);
    
    // =============================================
    // HÀNG RÀO CHU VI NHÀ MÁY (PERIMETER FENCE)
    // =============================================

    // Fence panels — North (split for main gate x:38~72)
    const nf1 = new THREE.Mesh(new THREE.BoxGeometry(78, 4, 0.3), fenceMat);
    nf1.position.set(-80, 2, 103); g.add(nf1);
    const nf2 = new THREE.Mesh(new THREE.BoxGeometry(28, 4, 0.3), fenceMat);
    nf2.position.set(84, 2, 103); g.add(nf2);
    // South fence
    const sf = new THREE.Mesh(new THREE.BoxGeometry(218, 4, 0.3), fenceMat);
    sf.position.set(-10, 2, -58); g.add(sf);
    // East fence
    const ef = new THREE.Mesh(new THREE.BoxGeometry(0.3, 4, 161), fenceMat);
    ef.position.set(98, 2, 22.5); g.add(ef);
    // West fence (split for logistics gate z:-22~7)
    const wf1 = new THREE.Mesh(new THREE.BoxGeometry(0.3, 4, 36), fenceMat);
    wf1.position.set(-118, 2, -40); g.add(wf1);
    const wf2 = new THREE.Mesh(new THREE.BoxGeometry(0.3, 4, 96), fenceMat);
    wf2.position.set(-118, 2, 55); g.add(wf2);

    // Fence posts along perimeter
    const fpGeo = new THREE.CylinderGeometry(0.35, 0.35, 5, 8);
    for (let x = -118; x <= 98; x += 10) {
      if (x > 35 && x < 75) continue;
      const pn = new THREE.Mesh(fpGeo, fenceMat); pn.position.set(x, 2.5, 103); g.add(pn);
      const ps = new THREE.Mesh(fpGeo, fenceMat); ps.position.set(x, 2.5, -58); g.add(ps);
    }
    for (let z = -58; z <= 103; z += 10) {
      const pe = new THREE.Mesh(fpGeo, fenceMat); pe.position.set(98, 2.5, z); g.add(pe);
      if (z > -25 && z < 10) continue;
      const pw = new THREE.Mesh(fpGeo, fenceMat); pw.position.set(-118, 2.5, z); g.add(pw);
    }

    // Gate poles — Cổng Chính & Cổng Phụ Logistics
    [{x:38,z:103},{x:72,z:103},{x:-118,z:-22},{x:-118,z:7}].forEach(p => {
      const pole = new THREE.Mesh(gatePoleGeo, fenceMat);
      pole.position.set(p.x, 4, p.z); g.add(pole);
    });

    // =============================================
    // ĐƯỜNG NỘI BỘ (INTERNAL RING ROADS)
    // =============================================
    const roadMat3 = new THREE.MeshStandardMaterial({ color: 0x1e293b, roughness: 0.9 });
    // Main entry road from north gate
    const mr = new THREE.Mesh(new THREE.BoxGeometry(18, 0.25, 35), roadMat3);
    mr.position.set(55, 0.05, 88); g.add(mr);
    // West ring road
    const rww = new THREE.Mesh(new THREE.BoxGeometry(10, 0.25, 140), roadMat3);
    rww.position.set(-102, 0.05, 20); g.add(rww);
    // South ring road
    const rss = new THREE.Mesh(new THREE.BoxGeometry(190, 0.25, 8), roadMat3);
    rss.position.set(-8, 0.05, -52); g.add(rss);
    // East ring road
    const ree = new THREE.Mesh(new THREE.BoxGeometry(8, 0.25, 140), roadMat3);
    ree.position.set(92, 0.05, 20); g.add(ree);
    // Connection road to logistics gate
    const rlg = new THREE.Mesh(new THREE.BoxGeometry(18, 0.25, 10), roadMat3);
    rlg.position.set(-108, 0.05, -8); g.add(rlg);

    // =============================================
    // CÂY XANH CẢNH QUAN (LANDSCAPING TREES)
    // =============================================
    const trunkMat = new THREE.MeshStandardMaterial({ color: 0x78350f });
    const leafMat = new THREE.MeshStandardMaterial({ color: 0x16a34a });
    const trGeo = new THREE.CylinderGeometry(0.4, 0.5, 5, 8);
    const lfGeo = new THREE.SphereGeometry(3, 8, 8);
    [[-105,95],[-90,95],[-75,95],[-60,95],[-45,95],[85,95],
     [92,80],[92,60],[92,40],[92,20],[92,0],
     [-105,-50],[-90,-50],[-75,-50],[-60,-50],
     [25,95],[10,95],[-5,95],[-20,95]].forEach(([tx,tz]) => {
      const tr = new THREE.Mesh(trGeo, trunkMat);
      tr.position.set(tx, 2.5, tz); g.add(tr);
      const lf = new THREE.Mesh(lfGeo, leafMat);
      lf.position.set(tx, 6.5, tz); g.add(lf);
    });

    // BÃI ĐỖ XE Ô TÔ (CAR PARKING near main gate)
    const bayMat2 = new THREE.MeshBasicMaterial({ color: 0xffffff });
    for (let i = 0; i < 8; i++) {
      const bay = new THREE.Mesh(new THREE.PlaneGeometry(0.15, 4.5), bayMat2);
      bay.rotation.x = -Math.PI / 2;
      bay.position.set(78 + i * 2.8, 0.15, 92);
      g.add(bay);
    }
  }

  buildRoof() {
    const g = this.groups.roof;
    const roofGeo = new THREE.BoxGeometry(186, 0.8, 116);
    const roofMat = new THREE.MeshStandardMaterial({ color: 0x1e293b, metalness: 0.5, roughness: 0.4, transparent: true, opacity: 0.25 });
    const roof = new THREE.Mesh(roofGeo, roofMat);
    roof.position.set(5, 37, -5);
    g.add(roof);
  }

  // 3D Cable Trays & Riser Network (Máng Cáp & Ống Cáp Trục)
  buildCableTrayTrunking() {
    const g = this.groups.cableTrays;
    const trayMat = new THREE.MeshStandardMaterial({ color: 0x64748b, metalness: 0.8, roughness: 0.3 });

    // Main 1F Cable Tray Trunk (Spanning warehouse, production, offices)
    const tray1Geo = new THREE.BoxGeometry(160, 0.5, 2.5);
    const tray1 = new THREE.Mesh(tray1Geo, trayMat);
    tray1.position.set(5, 11.5, -10);
    g.add(tray1);

    // 2F Cable Tray Trunk
    const tray2Geo = new THREE.BoxGeometry(70, 0.5, 2.5);
    const tray2 = new THREE.Mesh(tray2Geo, trayMat);
    tray2.position.set(58, 33.5, -10);
    g.add(tray2);

    // Vertical Riser Shaft Conduit (Cáp quang xuyên tầng)
    const riserGeo = new THREE.BoxGeometry(2.0, 32, 2.0);
    const riser = new THREE.Mesh(riserGeo, trayMat);
    riser.position.set(45, 16, -25);
    g.add(riser);

    // Glowing Fiber Lines
    const fiberMat = new THREE.LineDashedMaterial({ color: 0x22d3ee, dashSize: 3, gapSize: 1.5, linewidth: 2.5 });
    const rackEndpoints = [
      new THREE.Vector3(86, 2, 55),
      new THREE.Vector3(55, 2, 60),
      new THREE.Vector3(-20, 2, 50),
      new THREE.Vector3(-25, 2, 72),
      new THREE.Vector3(73, 25, 45)
    ];

    rackEndpoints.forEach(pt => {
      const points = [
        new THREE.Vector3(45, 25, -25),
        new THREE.Vector3(pt.x, 25, -25),
        new THREE.Vector3(pt.x, pt.y, pt.z)
      ];
      const geo = new THREE.BufferGeometry().setFromPoints(points);
      const line = new THREE.Line(geo, fiberMat);
      line.computeLineDistances();
      g.add(line);
    });
  }

  // ĐỒNG BỘ TOÀN BỘ 5 HỆ THỐNG THIẾT BỊ ELV
  syncAllAssets(data) {
    // Clear old assets
    while (this.groups.beacons.children.length > 0) this.groups.beacons.remove(this.groups.beacons.children[0]);
    while (this.groups.racks.children.length > 0) this.groups.racks.remove(this.groups.racks.children[0]);
    while (this.groups.cameras.children.length > 0) this.groups.cameras.remove(this.groups.cameras.children[0]);
    while (this.groups.wifi.children.length > 0) this.groups.wifi.remove(this.groups.wifi.children[0]);
    while (this.groups.pa.children.length > 0) this.groups.pa.remove(this.groups.pa.children[0]);
    this.allDevices.clear();

    // 1. Sync Access Control, Time Attendance & Barrier Devices
    (data.devices || []).forEach(dev => {
      const pos = this.calculateDevice3DPosition(dev);
      const beaconObj = this.createFaceIdBeacon(dev, pos);
      this.groups.beacons.add(beaconObj.group);
      this.allDevices.set(dev.id, { group: beaconObj.group, ring: beaconObj.ring, orb: beaconObj.orb, data: dev, type: dev.type, pos3D: pos });
    });

    // 2. Sync 10 IT Racks & Cabinets (RACK_MAIN 42U, RACK_PA 27U, Floor Racks, Outside Box)
    (data.itRacks || []).forEach(rack => {
      const pos = this.calculateRack3DPosition(rack);
      const rackObj = this.create3DRackCabinet(rack, pos);
      this.groups.racks.add(rackObj.group);
      this.allDevices.set(rack.id, { group: rackObj.group, data: rack, type: 'IT_RACK', pos3D: pos });
    });

    // 3. Sync CCTV Cameras (Bullet, Dome, Flame, Explosion-proof)
    (data.cctvCameras || []).forEach(cam => {
      const pos = this.calculateCamera3DPosition(cam);
      const camObj = this.create3DCameraMesh(cam, pos);
      this.groups.cameras.add(camObj.group);
      this.allDevices.set(cam.id, { group: camObj.group, data: cam, type: 'CCTV', pos3D: pos });
    });

    // 4. Sync Wi-Fi 6 Access Points (AP-01 to AP-08)
    (data.wifiAccessPoints || []).forEach(ap => {
      const pos = this.calculateWifi3DPosition(ap);
      const apObj = this.create3DWifiMesh(ap, pos);
      this.groups.wifi.add(apObj.group);
      this.allDevices.set(ap.id, { group: apObj.group, data: ap, type: 'WIFI', pos3D: pos });
    });

    // 5. Sync PA Public Address Audio Speaker Clusters (Ceiling, Wall, Horn)
    (data.paSpeakers || []).forEach(spk => {
      const pos = this.calculatePa3DPosition(spk);
      const spkObj = this.create3DPaSpeakerMesh(spk, pos);
      this.groups.pa.add(spkObj.group);
      this.allDevices.set(spk.id, { group: spkObj.group, data: spk, type: 'PA', pos3D: pos });
    });
  }

  // Tọa độ 3D
  calculateDevice3DPosition(dev) {
    const floor = dev.floor;
    let y = 1.8;
    if (floor === '1F') {
      let x = (dev.x - 50) * 1.7;
      let z = (dev.y - 50) * 1.1 - 10;
      return new THREE.Vector3(x, 1.8, z);
    } else if (floor === '1.5F') {
      let x = 60 + (dev.x - 50) * 0.7;
      let z = -10 + (dev.y - 50) * 0.7;
      return new THREE.Vector3(x, 15.8, z);
    } else if (floor === '2F') {
      let x = (dev.x - 50) * 1.2 + 20;
      let z = (dev.y - 50) * 1.1 - 10;
      return new THREE.Vector3(x, 25.8, z);
    } else if (floor === 'PARKING') {
      let idx = parseInt(dev.id.replace('AC-', '')) - 10;
      if (isNaN(idx) || idx < 0) idx = 0;
      return new THREE.Vector3(-58 + idx * 7.5, 2.8, 72);
    }
    return new THREE.Vector3(0, 2, 0);
  }

  calculateRack3DPosition(rack) {
    if (rack.id === 'RACK_MAIN') return new THREE.Vector3(43, 24.5, -25);
    if (rack.id === 'RACK_PA') return new THREE.Vector3(48, 24.5, -25);
    if (rack.id === 'RACK_01') return new THREE.Vector3(86, 0.5, 5);
    if (rack.id === 'RACK_02') return new THREE.Vector3(55, 0.5, -25);
    if (rack.id === 'RACK_03') return new THREE.Vector3(-55, 0.5, -15);
    if (rack.id === 'RACK_04') return new THREE.Vector3(73, 24.5, -10);
    if (rack.id === 'RACK_05') return new THREE.Vector3(46, 0.5, 20);
    if (rack.id === 'RACK_06') return new THREE.Vector3(35, 0.5, 72);
    if (rack.id === 'RACK_07') return new THREE.Vector3(-95, 0.5, -10);
    if (rack.id === 'RACK_08') return new THREE.Vector3(-25, 0.5, 60);
    if (rack.id === 'BOX_OUTSIDE') return new THREE.Vector3(85, 0.5, 40);
    return new THREE.Vector3(0, 1, 0);
  }

  calculateCamera3DPosition(cam) {
    const floor = cam.floor;
    let y = 11.5;
    if (floor === '2F') y = 34.5;
    if (floor === 'PARKING') y = 8.5;

    let x = (cam.x - 50) * 1.6;
    let z = (cam.y - 50) * 1.1 - 10;
    if (floor === 'PARKING') z = 72 + (cam.y - 50) * 0.4;
    return new THREE.Vector3(x, y, z);
  }

  calculateWifi3DPosition(ap) {
    const floor = ap.floor;
    let y = 11.8;
    if (floor === '1.5F') y = 22.5;
    if (floor === '2F') y = 34.8;
    if (floor === 'PARKING') y = 8.5;

    let x = (ap.x - 50) * 1.5;
    let z = (ap.y - 50) * 1.1 - 10;
    if (floor === 'PARKING') z = 72;
    return new THREE.Vector3(x, y, z);
  }

  calculatePa3DPosition(spk) {
    const floor = spk.floor;
    let y = 11.2;
    if (floor === '2F') y = 34.2;
    if (floor === 'PARKING') y = 8.0;

    let x = (spk.x - 50) * 1.5;
    let z = (spk.y - 50) * 1.1 - 10;
    if (floor === 'PARKING') z = 65;
    return new THREE.Vector3(x, y, z);
  }

  // 1. Face ID Beacon
  createFaceIdBeacon(dev, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    let color = 0x6366f1;
    if (dev.type === 'TA') color = 0x06b6d4;
    if (dev.type === 'BARRIER') color = 0xf59e0b;

    const orbGeo = new THREE.OctahedronGeometry(1.3, 0);
    const orbMat = new THREE.MeshStandardMaterial({ color, emissive: color, emissiveIntensity: 0.95, roughness: 0.1, metalness: 0.8 });
    const orb = new THREE.Mesh(orbGeo, orbMat);
    orb.position.y = 1.4;
    orb.castShadow = true;
    group.add(orb);

    const beamGeo = new THREE.CylinderGeometry(0.1, 0.1, 2.8, 8);
    const beamMat = new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 0.85 });
    const beam = new THREE.Mesh(beamGeo, beamMat);
    beam.position.y = 0.2;
    group.add(beam);

    const ringGeo = new THREE.RingGeometry(1.0, 1.8, 32);
    const ringMat = new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 0.85, side: THREE.DoubleSide });
    const ring = new THREE.Mesh(ringGeo, ringMat);
    ring.rotation.x = -Math.PI / 2;
    ring.position.y = -0.9;
    group.add(ring);

    const tagSprite = this.createFloatingTextSprite(dev.code, color);
    tagSprite.position.set(0, 3.8, 0);
    tagSprite.scale.set(10, 2.5, 1);
    group.add(tagSprite);

    orb.userData = { isDevice: true, deviceId: dev.id, deviceData: dev };
    ring.userData = { isDevice: true, deviceId: dev.id, deviceData: dev };

    return { group, ring, orb };
  }

  // 2. 3D IT Rack Cabinet
  create3DRackCabinet(rack, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    const isMain42U = rack.id === 'RACK_MAIN';
    const isPa27U = rack.id === 'RACK_PA';
    const rw = isMain42U ? 5.5 : (isPa27U ? 4.5 : 3.8);
    const rh = isMain42U ? 10.5 : (isPa27U ? 8.2 : 6.0);
    const rd = isMain42U ? 5.0 : (isPa27U ? 4.2 : 3.5);

    const cabMat = new THREE.MeshStandardMaterial({ color: 0x0a101d, metalness: 0.9, roughness: 0.2 });
    const cabGeo = new THREE.BoxGeometry(rw, rh, rd);
    const cab = new THREE.Mesh(cabGeo, cabMat);
    cab.position.y = rh / 2;
    cab.castShadow = true;
    group.add(cab);

    const glassMat = new THREE.MeshPhysicalMaterial({ color: isPa27U ? 0xa855f7 : 0x38bdf8, transparent: true, opacity: 0.5, roughness: 0.1, metalness: 0.3 });
    const doorGeo = new THREE.BoxGeometry(rw - 0.4, rh - 0.6, 0.2);
    const door = new THREE.Mesh(doorGeo, glassMat);
    door.position.set(0, rh / 2, rd / 2 + 0.1);
    group.add(door);

    const ledMat = new THREE.MeshBasicMaterial({ color: isMain42U ? 0x10b981 : (isPa27U ? 0xa855f7 : 0x06b6d4) });
    const uCount = isMain42U ? 6 : (isPa27U ? 5 : 3);
    for (let u = 0; u < uCount; u++) {
      const uGeo = new THREE.BoxGeometry(rw - 0.8, 0.6, rd - 0.6);
      const uMat = new THREE.MeshStandardMaterial({ color: 0x1e293b, metalness: 0.8 });
      const uMesh = new THREE.Mesh(uGeo, uMat);
      uMesh.position.set(0, 1.5 + u * 1.4, 0);
      group.add(uMesh);

      const ledGeo = new THREE.BoxGeometry(rw - 1.2, 0.15, 0.1);
      const led = new THREE.Mesh(ledGeo, ledMat);
      led.position.set(0, 1.5 + u * 1.4, rd / 2 + 0.12);
      group.add(led);
      this.pulsingObjects.push({ mesh: led, speed: 2.5 + u * 0.5 });
    }

    const tagColor = isMain42U ? 0x10b981 : (isPa27U ? 0xa855f7 : 0x06b6d4);
    const tagSprite = this.createFloatingTextSprite(rack.code, tagColor);
    tagSprite.position.set(0, rh + 2.8, 0);
    tagSprite.scale.set(13, 3.2, 1);
    group.add(tagSprite);

    cab.userData = { isDevice: true, deviceId: rack.id, deviceData: rack };
    door.userData = { isDevice: true, deviceId: rack.id, deviceData: rack };

    return { group };
  }

  // 3. 3D CCTV Camera with Vision Cone
  create3DCameraMesh(cam, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    const isFlame = cam.id.includes('FLAME');
    const isEx = cam.id.includes('EX');
    const camColor = isFlame ? 0xef4444 : (isEx ? 0xf59e0b : 0x06b6d4);

    const bodyMat = new THREE.MeshStandardMaterial({ color: isFlame ? 0xef4444 : (isEx ? 0xd97706 : 0xffffff), metalness: 0.8, roughness: 0.2 });
    const camGeo = new THREE.CylinderGeometry(0.6, 0.9, 2.2, 16);
    const camMesh = new THREE.Mesh(camGeo, bodyMat);
    camMesh.rotation.x = Math.PI / 3;
    group.add(camMesh);

    const lensMat = new THREE.MeshBasicMaterial({ color: camColor });
    const lensGeo = new THREE.CylinderGeometry(0.4, 0.4, 0.3, 16);
    const lens = new THREE.Mesh(lensGeo, lensMat);
    lens.position.set(0, -0.9, 0.8);
    lens.rotation.x = Math.PI / 3;
    group.add(lens);

    const coneGeo = new THREE.ConeGeometry(8, 14, 16, 1, true);
    const coneMat = new THREE.MeshBasicMaterial({ color: camColor, transparent: true, opacity: 0.12, side: THREE.DoubleSide });
    const cone = new THREE.Mesh(coneGeo, coneMat);
    cone.position.set(0, -7, 4.5);
    cone.rotation.x = -Math.PI / 4;
    group.add(cone);

    const tagSprite = this.createFloatingTextSprite(cam.code, camColor);
    tagSprite.position.set(0, 3.2, 0);
    tagSprite.scale.set(11, 2.8, 1);
    group.add(tagSprite);

    camMesh.userData = { isDevice: true, deviceId: cam.id, deviceData: cam };
    lens.userData = { isDevice: true, deviceId: cam.id, deviceData: cam };

    return { group, cone };
  }

  // 4. 3D Wi-Fi 6 Access Point
  create3DWifiMesh(ap, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    // Ceiling Disc
    const apGeo = new THREE.CylinderGeometry(1.6, 1.8, 0.5, 24);
    const apMat = new THREE.MeshStandardMaterial({ color: 0xffffff, metalness: 0.4, roughness: 0.3 });
    const apMesh = new THREE.Mesh(apGeo, apMat);
    group.add(apMesh);

    // Glowing Wi-Fi Center LED
    const ledGeo = new THREE.CylinderGeometry(0.5, 0.5, 0.55, 16);
    const ledMat = new THREE.MeshBasicMaterial({ color: 0x3b82f6 });
    const led = new THREE.Mesh(ledGeo, ledMat);
    group.add(led);

    // Wi-Fi RF Wave Signal Ring
    const waveGeo = new THREE.RingGeometry(2.5, 3.0, 32);
    const waveMat = new THREE.MeshBasicMaterial({ color: 0x3b82f6, transparent: true, opacity: 0.45, side: THREE.DoubleSide });
    const wave = new THREE.Mesh(waveGeo, waveMat);
    wave.rotation.x = -Math.PI / 2;
    wave.position.y = -0.3;
    group.add(wave);
    this.pulsingObjects.push({ mesh: wave, speed: 3.0 });

    const tagSprite = this.createFloatingTextSprite(ap.code, 0x3b82f6);
    tagSprite.position.set(0, 2.8, 0);
    tagSprite.scale.set(10, 2.5, 1);
    group.add(tagSprite);

    apMesh.userData = { isDevice: true, deviceId: ap.id, deviceData: ap };
    return { group };
  }

  // 5. 3D Public Address (PA) Audio Speaker
  create3DPaSpeakerMesh(spk, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    const isHorn = spk.type === 'HORN';
    const isWall = spk.type === 'WALL';

    let spkMesh;
    if (isHorn) {
      // Outdoor Horn Speaker
      const hGeo = new THREE.ConeGeometry(1.8, 3.2, 16);
      const hMat = new THREE.MeshStandardMaterial({ color: 0x94a3b8, metalness: 0.8 });
      spkMesh = new THREE.Mesh(hGeo, hMat);
      spkMesh.rotation.z = Math.PI / 2;
    } else if (isWall) {
      // Wall Box Speaker
      const wGeo = new THREE.BoxGeometry(1.8, 2.6, 1.2);
      const wMat = new THREE.MeshStandardMaterial({ color: 0x334155, metalness: 0.5 });
      spkMesh = new THREE.Mesh(wGeo, wMat);
    } else {
      // Ceiling Flush Speaker
      const cGeo = new THREE.CylinderGeometry(1.4, 1.4, 0.4, 24);
      const cMat = new THREE.MeshStandardMaterial({ color: 0xf8fafc, metalness: 0.2 });
      spkMesh = new THREE.Mesh(cGeo, cMat);
    }
    group.add(spkMesh);

    const tagSprite = this.createFloatingTextSprite(`${spk.code} (${spk.qty} Loa)`, 0xa855f7);
    tagSprite.position.set(0, 2.8, 0);
    tagSprite.scale.set(12, 3.0, 1);
    group.add(tagSprite);

    spkMesh.userData = { isDevice: true, deviceId: spk.id, deviceData: spk };
    return { group };
  }

  // BỘ LỌC LỚP THIẾT BỊ (ALL, IT_RACK, CCTV, WIFI, PA, AC, TA, BARRIER)
  setDeviceLayerFilter(layer) {
    this.activeLayer = layer;

    this.groups.racks.visible = (layer === 'ALL' || layer === 'IT_RACK');
    this.groups.cameras.visible = (layer === 'ALL' || layer === 'CCTV');
    this.groups.wifi.visible = (layer === 'ALL' || layer === 'WIFI');
    this.groups.pa.visible = (layer === 'ALL' || layer === 'PA');
    this.groups.cableTrays.visible = (layer === 'ALL' || layer === 'IT_RACK');

    this.allDevices.forEach(item => {
      if (item.type === 'AC' || item.type === 'TA' || item.type === 'BARRIER') {
        if (layer === 'ALL' || layer === item.type || layer === 'TA_AC') {
          item.group.visible = (this.activeFloor === 'ALL' || item.data.floor === this.activeFloor);
        } else {
          item.group.visible = false;
        }
      }
    });
  }

  triggerEventAlert(deviceId, eventData = {}) {
    const item = this.allDevices.get(deviceId);
    if (!item) return;

    const pos = item.pos3D;
    const shockGeo = new THREE.CylinderGeometry(2.8, 2.8, 30, 32, 1, true);
    const shockMat = new THREE.MeshBasicMaterial({ color: 0x22c55e, transparent: true, opacity: 0.95, side: THREE.DoubleSide });
    const shockPillar = new THREE.Mesh(shockGeo, shockMat);
    shockPillar.position.set(pos.x, pos.y + 12, pos.z);
    this.groups.effects.add(shockPillar);

    let scale = 1.0;
    let opacity = 0.95;
    const interval = setInterval(() => {
      scale += 0.14;
      opacity -= 0.05;
      shockPillar.scale.set(scale, 1, scale);
      shockMat.opacity = Math.max(0, opacity);

      if (opacity <= 0) {
        clearInterval(interval);
        this.groups.effects.remove(shockPillar);
        shockGeo.dispose();
        shockMat.dispose();
      }
    }, 30);

    if (item.orb) {
      item.orb.material.emissive.setHex(0x22c55e);
      setTimeout(() => {
        let defaultColor = 0x6366f1;
        if (item.data.type === 'TA') defaultColor = 0x06b6d4;
        if (item.data.type === 'BARRIER') defaultColor = 0xf59e0b;
        item.orb.material.emissive.setHex(defaultColor);
      }, 4000);
    }
  }

  setupInteractions() {
    const dom = this.renderer.domElement;

    dom.addEventListener('mousemove', (e) => {
      const rect = dom.getBoundingClientRect();
      this.mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
      this.mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;
      this.checkHover();
    });

    dom.addEventListener('click', (e) => {
      const rect = dom.getBoundingClientRect();
      this.mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
      this.mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;
      this.checkClick();
    });
  }

  checkHover() {
    this.raycaster.setFromCamera(this.mouse, this.camera);
    const targets = [
      ...this.groups.beacons.children,
      ...this.groups.racks.children,
      ...this.groups.cameras.children,
      ...this.groups.wifi.children,
      ...this.groups.pa.children
    ];
    const intersects = this.raycaster.intersectObjects(targets, true);

    const dom = this.renderer.domElement;
    if (intersects.length > 0) {
      const hit = intersects.find(i => i.object.userData && i.object.userData.isDevice);
      if (hit) {
        dom.style.cursor = 'pointer';
        if (this.options.onDeviceHover) this.options.onDeviceHover(hit.object.userData.deviceData);
        return;
      }
    }
    dom.style.cursor = 'default';
  }

  checkClick() {
    this.raycaster.setFromCamera(this.mouse, this.camera);
    const targets = [
      ...this.groups.beacons.children,
      ...this.groups.racks.children,
      ...this.groups.cameras.children,
      ...this.groups.wifi.children,
      ...this.groups.pa.children
    ];
    const intersects = this.raycaster.intersectObjects(targets, true);

    if (intersects.length > 0) {
      const hit = intersects.find(i => i.object.userData && i.object.userData.isDevice);
      if (hit) {
        const dev = hit.object.userData.deviceData;
        this.focusOnDevice(dev.id);
        if (this.options.onDeviceClick) this.options.onDeviceClick(dev);
      }
    }
  }

  focusOnDevice(deviceId) {
    const item = this.allDevices.get(deviceId);
    if (!item || !this.controls) return;

    const targetPos = item.pos3D;
    const camTarget = new THREE.Vector3(targetPos.x + 24, targetPos.y + 18, targetPos.z + 28);
    this.smoothMoveCamera(camTarget, targetPos, 900);
  }

  setFloorView(floor) {
    this.activeFloor = floor;

    this.groups.ground.visible = true;
    this.groups.floor1.visible = (floor === 'ALL' || floor === '1F');
    this.groups.floor1_5.visible = (floor === 'ALL' || floor === '1.5F');
    this.groups.floor2.visible = (floor === 'ALL' || floor === '2F');
    this.groups.parking.visible = (floor === 'ALL' || floor === 'PARKING');
    this.groups.roof.visible = (floor === 'ALL');

    this.allDevices.forEach((item) => {
      const matchFloor = (floor === 'ALL' || item.data.floor === floor);
      const matchLayer = (this.activeLayer === 'ALL' || this.activeLayer === item.type);
      item.group.visible = (matchFloor && matchLayer);
    });

    if (floor === '1F') {
      this.smoothMoveCamera(new THREE.Vector3(80, 55, 90), new THREE.Vector3(10, 5, 0), 900);
    } else if (floor === '1.5F') {
      this.smoothMoveCamera(new THREE.Vector3(100, 45, 30), new THREE.Vector3(60, 16, -10), 900);
    } else if (floor === '2F') {
      this.smoothMoveCamera(new THREE.Vector3(105, 65, 50), new THREE.Vector3(55, 26, -10), 900);
    } else if (floor === 'PARKING') {
      this.smoothMoveCamera(new THREE.Vector3(-10, 40, 130), new THREE.Vector3(-25, 2, 72), 900);
    } else {
      this.smoothMoveCamera(this.defaultCameraPos, this.targetLookAt, 900);
    }
  }

  toggleExplodedView() {
    this.isExploded = !this.isExploded;

    const targetY1_5 = this.isExploded ? 32 : 0;
    const targetY2 = this.isExploded ? 65 : 0;
    const targetYRoof = this.isExploded ? 95 : 0;

    this.animateProperty(this.groups.floor1_5.position, 'y', targetY1_5, 700);
    this.animateProperty(this.groups.floor2.position, 'y', targetY2, 700);
    this.animateProperty(this.groups.roof.position, 'y', targetYRoof, 700);

    this.allDevices.forEach(item => {
      if (item.data.floor === '1.5F') {
        this.animateProperty(item.group.position, 'y', item.pos3D.y + (this.isExploded ? 32 : 0), 700);
      } else if (item.data.floor === '2F') {
        this.animateProperty(item.group.position, 'y', item.pos3D.y + (this.isExploded ? 65 : 0), 700);
      }
    });

    return this.isExploded;
  }

  toggleXRay() {
    this.isXRay = !this.isXRay;
    const opacity = this.isXRay ? 0.32 : 0.88;

    [this.groups.floor1, this.groups.floor1_5, this.groups.floor2, this.groups.parking].forEach(group => {
      group.traverse(child => {
        if (child.isMesh && child.material && child.material.isMeshPhysicalMaterial) {
          child.material.opacity = opacity;
        }
      });
    });
    return this.isXRay;
  }

  toggleAutoRotate() {
    this.isAutoRotate = !this.isAutoRotate;
    if (this.controls) {
      this.controls.autoRotate = this.isAutoRotate;
      this.controls.autoRotateSpeed = 1.2;
    }
    return this.isAutoRotate;
  }

  resetCamera() {
    this.smoothMoveCamera(this.defaultCameraPos, this.targetLookAt, 800);
  }

  smoothMoveCamera(targetCamPos, targetLookAt, duration = 800) {
    if (!this.controls) return;

    const startPos = this.camera.position.clone();
    const startTarget = this.controls.target.clone();
    const startTime = performance.now();

    const update = (now) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const ease = progress < 0.5 ? 4 * progress * progress * progress : 1 - Math.pow(-2 * progress + 2, 3) / 2;

      this.camera.position.lerpVectors(startPos, targetCamPos, ease);
      this.controls.target.lerpVectors(startTarget, targetLookAt, ease);
      this.controls.update();

      if (progress < 1) requestAnimationFrame(update);
    };
    requestAnimationFrame(update);
  }

  animateProperty(obj, prop, targetVal, duration = 600) {
    const startVal = obj[prop];
    const startTime = performance.now();

    const update = (now) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const ease = 0.5 - Math.cos(progress * Math.PI) / 2;
      obj[prop] = startVal + (targetVal - startVal) * ease;
      if (progress < 1) requestAnimationFrame(update);
    };
    requestAnimationFrame(update);
  }

  onWindowResize() {
    if (!this.container || !this.renderer || !this.camera) return;
    const width = this.container.clientWidth || 900;
    const height = this.container.clientHeight || 680;

    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  animate() {
    this.animationId = requestAnimationFrame(() => this.animate());

    // Skip heavy calculations if viewport is hidden
    if (this.container && this.container.offsetParent === null) return;

    const delta = this.clock.getDelta();
    const time = this.clock.getElapsedTime();

    // Fast device animation loop
    const sinT3 = Math.sin(time * 3);
    const sinT4 = Math.sin(time * 4);
    
    this.allDevices.forEach(item => {
      if (!item.group || !item.group.visible) return;
      if (item.orb) {
        item.orb.rotation.y += delta * 1.5;
        item.orb.position.y = 1.4 + sinT3 * 0.18;
      }
      if (item.ring) {
        const ringScale = 1.0 + sinT4 * 0.18;
        item.ring.scale.set(ringScale, ringScale, 1);
      }
    });

    this.pulsingObjects.forEach(p => {
      if (p.mesh && p.mesh.material && p.mesh.visible) {
        p.mesh.material.opacity = 0.35 + Math.sin(time * p.speed) * 0.55;
      }
    });

    if (this.controls) this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }

  destroy() {
    if (this.animationId) cancelAnimationFrame(this.animationId);
    if (this.renderer && this.renderer.domElement) {
      this.container.removeChild(this.renderer.domElement);
      this.renderer.dispose();
    }
  }
}

window.Factory3DEngine = Factory3DEngine;
