/**
 * VINATECH HƯNG YÊN — SMART FACTORY 3D DIGITAL TWIN & ELV MASTER ENGINE
 * 100% Verified against Drawing_ELV System_VINATECH_260615_v5.2.pdf
 * Focused Core Systems: IT Racks & Fiber Backbone, Wi-Fi 6, TA/AC & Flap Barrier, Network LAN/TEL Outlets
 * (Excluded: CCTV & PA according to system specifications)
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
      wifi: new THREE.Group(),
      beacons: new THREE.Group(),
      outlets: new THREE.Group(),
      roomTags: new THREE.Group(),
      effects: new THREE.Group()
    };

    this.allDevices = new Map();
    this.pulsingObjects = [];
    this.activeFloor = 'ALL';
    this.activeLayer = 'ALL';
    this.isExploded = false;
    this.isXRay = true;
    this.isAutoRotate = false;
    this.animationId = null;
    this.clock = new THREE.Clock();

    this.defaultCameraPos = new THREE.Vector3(-80, 120, -160);
    this.targetLookAt = new THREE.Vector3(0, 8, 0);

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

    this.camera = new THREE.PerspectiveCamera(40, width / height, 1, 1600);
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
      this.controls.rotateSpeed = 0.85;
      this.controls.panSpeed = 0.9;
      this.controls.screenSpacePanning = true;
      this.controls.maxPolarAngle = Math.PI / 2 - 0.02;
      this.controls.minDistance = 20;
      this.controls.maxDistance = 600;
      this.controls.target.copy(this.targetLookAt);
    }

    Object.values(this.groups).forEach(g => this.scene.add(g));
  }

  initLights() {
    const ambientLight = new THREE.AmbientLight(0xdce7ff, 0.95);
    this.scene.add(ambientLight);

    const dirLight = new THREE.DirectionalLight(0xffffff, 1.15);
    dirLight.position.set(-100, 180, -90);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.width = 1024;
    dirLight.shadow.mapSize.height = 1024;
    dirLight.shadow.camera.near = 10;
    dirLight.shadow.camera.far = 450;
    const d = 140;
    dirLight.shadow.camera.left = -d;
    dirLight.shadow.camera.right = d;
    dirLight.shadow.camera.top = d;
    dirLight.shadow.camera.bottom = -d;
    this.scene.add(dirLight);

    // Accent Lights for Key Areas
    const itLight = new THREE.PointLight(0x10b981, 2.5, 80);
    itLight.position.set(-70, 30, -32);
    this.scene.add(itLight);

    const officeLight = new THREE.PointLight(0x6366f1, 2.0, 90);
    officeLight.position.set(-50, 30, -30);
    this.scene.add(officeLight);

    const prodLight = new THREE.PointLight(0x06b6d4, 2.2, 110);
    prodLight.position.set(5, 20, -5);
    this.scene.add(prodLight);

    const whLight = new THREE.PointLight(0xf59e0b, 1.8, 80);
    whLight.position.set(-65, 18, 5);
    this.scene.add(whLight);

    const parkLight = new THREE.PointLight(0x38bdf8, 2.0, 90);
    parkLight.position.set(50, 15, -60);
    this.scene.add(parkLight);
  }

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

  // Campus Ground, Master Plan Roadways & Grid
  buildCampusGround() {
    const isLight = (document.documentElement.getAttribute('data-theme') === 'light');
    const groundGeo = new THREE.PlaneGeometry(600, 600);
    const groundMat = new THREE.MeshStandardMaterial({ color: isLight ? 0xcbd5e1 : 0x0a0f1d, roughness: 0.85, metalness: 0.2 });
    const ground = new THREE.Mesh(groundGeo, groundMat);
    ground.rotation.x = -Math.PI / 2;
    ground.position.y = -0.4;
    ground.receiveShadow = true;
    this.groundMesh = ground;
    this.groups.ground.add(ground);

    const grid = new THREE.GridHelper(500, 100, 0x4338ca, 0x1e293b);
    grid.position.y = -0.2;
    this.groups.ground.add(grid);

    // Factory Foundation Pad (171.0m x 94.0m)
    const padGeo = new THREE.BoxGeometry(175, 1.0, 98);
    const padMat = new THREE.MeshStandardMaterial({ color: 0x111c2e, roughness: 0.5, metalness: 0.4 });
    const pad = new THREE.Mesh(padGeo, padMat);
    pad.position.set(0, 0, 0);
    pad.receiveShadow = true;
    this.groups.ground.add(pad);

    // Main Industrial Road along front (Đường nội khu KCN: z = -85)
    const roadMat = new THREE.MeshStandardMaterial({ color: 0x182234, roughness: 0.8 });
    const roadGeo = new THREE.BoxGeometry(260, 0.4, 25);
    const road = new THREE.Mesh(roadGeo, roadMat);
    road.position.set(0, -0.2, -88);
    road.receiveShadow = true;
    this.groups.ground.add(road);

    // E-Parking Pad (Nhà xe mặt trước xưởng)
    const parkPadGeo = new THREE.BoxGeometry(70, 0.8, 35);
    const parkPadMat = new THREE.MeshStandardMaterial({ color: 0x0f172a, roughness: 0.6, metalness: 0.4 });
    const parkPad = new THREE.Mesh(parkPadGeo, parkPadMat);
    parkPad.position.set(50, 0, -60);
    parkPad.receiveShadow = true;
    this.groups.ground.add(parkPad);
  }

  // Room Builder Utility
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
      opacity: this.isXRay ? 0.28 : 0.85,
      roughness: 0.1,
      metalness: 0.15,
      transmission: this.isXRay ? 0.72 : 0.15,
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

  // TẦNG 1 NHÀ XƯỞNG (1F - Cao độ 0m ~ 13m)
  buildFloor1() {
    const g = this.groups.floor1;
    const h = 13;

    // 1. Showroom 101 & Sảnh Chính (Trục 1X–3X / 1Y–3Y)
    this.createRoom({
      name: "Sảnh Chính & Showroom",
      labelTag: "🏛️ Sảnh Chính & Showroom 101",
      x: -68, z: -35, width: 32, depth: 25, height: h,
      color: 0x6366f1, floorColor: 0x1e1b4b,
      group: g, floorLevel: 0
    });

    // 2. P. Điều Khiển 128 & Mixer 1 (129) [Vị trí RACK_02] (Trục 4X–6X / 1Y–3Y)
    this.createRoom({
      name: "P. Điều Khiển & Mixer 1",
      labelTag: "🎛️ P. Điều Khiển 128 / Mixer 1 [RACK_02]",
      x: -35, z: -35, width: 28, depth: 25, height: h,
      color: 0x8b5cf6, floorColor: 0x1e1b4b,
      group: g, floorLevel: 0
    });

    // 3. QC Room 136, VP Xưởng 1 (118) & PCCC 151 [Vị trí RACK_03] (Trục 15X–18X / 1Y–3Y)
    this.createRoom({
      name: "QC 136 & PCCC 151",
      labelTag: "🧯 QC Room 136 & PCCC 151 [RACK_03]",
      x: 65, z: -35, width: 35, depth: 25, height: h,
      color: 0xef4444, floorColor: 0x3f1212,
      group: g, floorLevel: 0
    });

    // 4. Kho 1 (Warehouse 104) (Trục 1X–4X / 4Y–8Y)
    this.createRoom({
      name: "Kho 1",
      labelTag: "📦 Kho 1 (Warehouse 104)",
      x: -65, z: 5, width: 38, depth: 40, height: h,
      color: 0xf59e0b, floorColor: 0x292524,
      group: g, floorLevel: 0
    });

    // 5. Logistics Dock 105 (Kho Xuất Nhập) (Trục 3X–6X / 8Y–10Y)
    this.createRoom({
      name: "Logistics Dock 105",
      labelTag: "🚛 Logistics Dock 105",
      x: -45, z: 35, width: 35, depth: 22, height: h,
      color: 0xf59e0b, floorColor: 0x292524,
      group: g, floorLevel: 0
    });

    // 6. VP Xưởng 3 (109), Spare Parts 112 & P. Lắp Ráp 1 [Vị trí RACK_01] (Trục 7X–11X / 8Y–10Y)
    this.createRoom({
      name: "VP Xưởng 3 & Lắp Ráp 1",
      labelTag: "🔧 VP Xưởng 3 (109) [RACK_01]",
      x: 0, z: 35, width: 45, depth: 22, height: h,
      color: 0x0891b2, floorColor: 0x164e63,
      group: g, floorLevel: 0
    });

    // 7. Căn Tin 115A & Phòng Nghỉ Ca (Trục 15X–19X / 6Y–10Y)
    this.createRoom({
      name: "Căn Tin 115A & Nghỉ Ca",
      labelTag: "🍽️ Căn Tin 115A & Nghỉ Ca",
      x: 65, z: 25, width: 38, depth: 40, height: h,
      color: 0x10b981, floorColor: 0x064e3b,
      group: g, floorLevel: 0
    });

    // 8. Xưởng Sản Xuất Chính (Lắp Ráp 1, 2 & Định Hình 1) (Trục 5X–15X / 3Y–8Y)
    this.createRoom({
      name: "Xưởng Sản Xuất Supercapacitor",
      labelTag: "⚡ Xưởng Sản Xuất (Lắp Ráp & Định Hình)",
      x: 5, z: -5, width: 80, depth: 50, height: h,
      color: 0x06b6d4, floorColor: 0x0f2338,
      group: g, floorLevel: 0, isProduction: true
    });
  }

  // TẦNG 1.5 NHÀ XƯỞNG (1.5F - Cao độ 14m ~ 23m)
  buildFloor1_5() {
    const g = this.groups.floor1_5;
    const h = 9;
    const yBase = 14;

    this.createRoom({
      name: "Văn Phòng 1.5F",
      labelTag: "🏢 Văn Phòng 1.5F (P. 201 & 202)",
      x: -65, z: -30, width: 38, depth: 32, height: h,
      color: 0xa855f7, floorColor: 0x2e1065,
      group: g, floorLevel: yBase
    });
  }

  // TẦNG 2 NHÀ XƯỞNG (2F - Cao độ 24m ~ 36m)
  buildFloor2() {
    const g = this.groups.floor2;
    const h = 12;
    const yBase = 24;

    // 1. PHÒNG IT & SERVER 304 [RACK_MAIN 42U + RACK_PA 27U] (Trục 1X–2X / 2Y–3Y)
    this.createRoom({
      name: "Phòng IT & Server 304",
      labelTag: "💻 IT Server 304 [RACK_MAIN 42U]",
      x: -70, z: -32, width: 22, depth: 24, height: h,
      color: 0x10b981, floorColor: 0x064e3b,
      group: g, floorLevel: yBase
    });

    // 2. Khối Văn Phòng 302, P. Giám Đốc 303 (Trục 1X–4X / 1Y–4Y)
    this.createRoom({
      name: "Văn Phòng Chính 2F",
      labelTag: "👔 Khối Văn Phòng 2F (302 & 303)",
      x: -45, z: -30, width: 28, depth: 32, height: h,
      color: 0x6366f1, floorColor: 0x1e1b4b,
      group: g, floorLevel: yBase
    });

    // 3. Xưởng Sản Xuất Tầng 2 & Module Working 311 [RACK_04] (Trục 6X–11X / 7Y–10Y)
    this.createRoom({
      name: "Xưởng Sản Xuất 2F",
      labelTag: "📦 Xưởng 2F / Module Working 311 [RACK_04]",
      x: -10, z: 28, width: 50, depth: 35, height: h,
      color: 0x06b6d4, floorColor: 0x083344,
      group: g, floorLevel: yBase
    });

    // 4. Mixer 2 (306) (Trục 4X–6X / 1Y–3Y)
    this.createRoom({
      name: "Mixer 2 (306)",
      labelTag: "🔬 Mixer 2 (P.306)",
      x: -35, z: -35, width: 28, depth: 25, height: h,
      color: 0x0891b2, floorColor: 0x164e63,
      group: g, floorLevel: yBase
    });
  }

  // TOÀN BỘ KHUÔN VIÊN & 3 NHÀ BẢO VỆ + HÀNG RÀO CHU VI (MASTER PLAN)
  buildParkingAndGates() {
    const g = this.groups.parking;

    // 1. NHÀ BẢO VỆ 1 — CỔNG CHÍNH ĐÓN KHÁCH & Ô TÔ [RACK_06]
    this.createRoom({
      name: "Nhà Bảo Vệ 1",
      labelTag: "🛡️ Nhà Bảo Vệ 1 [Cổng Chính - RACK_06]",
      x: -65, z: -75, width: 14, depth: 14, height: 6.5,
      color: 0xf59e0b, floorColor: 0x451a03,
      group: g, floorLevel: 0
    });

    // 2. NHÀ BẢO VỆ 3 — CỔNG XE MÁY VÀO NHÀ XE E-PARKING [RACK_08]
    this.createRoom({
      name: "Nhà Bảo Vệ 3",
      labelTag: "🏍️ Nhà Bảo Vệ 3 [Cổng Xe Máy - RACK_08]",
      x: 35, z: -75, width: 14, depth: 14, height: 6.5,
      color: 0xf59e0b, floorColor: 0x451a03,
      group: g, floorLevel: 0
    });

    // 3. NHÀ BẢO VỆ 2 — CỔNG LOGISTICS XE TẢI KHO 104 [RACK_07]
    this.createRoom({
      name: "Nhà Bảo Vệ 2",
      labelTag: "🚛 Nhà Bảo Vệ 2 [Cổng Logistics - RACK_07]",
      x: -105, z: 35, width: 14, depth: 14, height: 6.5,
      color: 0xf59e0b, floorColor: 0x451a03,
      group: g, floorLevel: 0
    });

    // 4. TRẠM TIỆN ÍCH / XỬ LÝ NƯỚC THẢI & TRẠM BƠM PCCC [RACK_09]
    this.createRoom({
      name: "Trạm Tiện Ích & XLNT",
      labelTag: "♻️ Trạm Tiện Ích & XLNT [RACK_09]",
      x: -95, z: -15, width: 20, depth: 20, height: 7.5,
      color: 0x06b6d4, floorColor: 0x083344,
      group: g, floorLevel: 0
    });

    // 5. TRẠM BIẾN ÁP (SUBSTATION 22kV)
    this.createRoom({
      name: "Trạm Biến Áp",
      labelTag: "⚡ Trạm Biến Áp (Substation)",
      x: -95, z: 10, width: 20, depth: 16, height: 7.5,
      color: 0xeab308, floorColor: 0x422006,
      group: g, floorLevel: 0
    });

    // Mái che Khu Nhà Xe E-Parking [Vị trí RACK_05]
    const roofMat = new THREE.MeshStandardMaterial({ color: 0x1e293b, metalness: 0.6, roughness: 0.3, transparent: true, opacity: 0.8 });
    const canopyGeo = new THREE.BoxGeometry(65, 0.6, 28);
    const canopy = new THREE.Mesh(canopyGeo, roofMat);
    canopy.position.set(50, 8.5, -60);
    canopy.castShadow = true;
    g.add(canopy);

    const pilMat = new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.8 });
    for (let px of [25, 50, 75]) {
      for (let pz of [-70, -50]) {
        const pGeo = new THREE.CylinderGeometry(0.5, 0.5, 8.5, 16);
        const pil = new THREE.Mesh(pGeo, pilMat);
        pil.position.set(px, 4.25, pz);
        pil.castShadow = true;
        g.add(pil);
      }
    }

    // 10 Làn Cổng Flap Barrier (5 Làn Vào + 5 Làn Ra)
    const barMat = new THREE.MeshStandardMaterial({ color: 0xe2e8f0, metalness: 0.9, roughness: 0.1 });
    const flapMat = new THREE.MeshStandardMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.75 });

    for (let i = 0; i < 10; i++) {
      const bx = 22 + i * 6.2;
      const bz = -60;

      const bGeo = new THREE.BoxGeometry(1.6, 2.6, 4.2);
      const barrier = new THREE.Mesh(bGeo, barMat);
      barrier.position.set(bx, 1.3, bz);
      barrier.castShadow = true;
      g.add(barrier);

      const fGeo = new THREE.BoxGeometry(0.2, 2.0, 1.4);
      const flap = new THREE.Mesh(fGeo, flapMat);
      flap.position.set(bx + 1.0, 1.4, bz);
      g.add(flap);
    }

    // HÀNG RÀO CHU VI NHÀ MÁY (PERIMETER FENCE & 3 GATES)
    const fenceMat = new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.7, roughness: 0.4 });
    const gatePoleGeo = new THREE.CylinderGeometry(0.8, 0.8, 8, 16);

    // Front Fence
    const nf1 = new THREE.Mesh(new THREE.BoxGeometry(35, 3.8, 0.3), fenceMat);
    nf1.position.set(-100, 1.9, -80); g.add(nf1);

    const nf2 = new THREE.Mesh(new THREE.BoxGeometry(75, 3.8, 0.3), fenceMat);
    nf2.position.set(-15, 1.9, -80); g.add(nf2);

    const nf3 = new THREE.Mesh(new THREE.BoxGeometry(45, 3.8, 0.3), fenceMat);
    nf3.position.set(80, 1.9, -80); g.add(nf3);

    // Rear Fence
    const sf = new THREE.Mesh(new THREE.BoxGeometry(240, 3.8, 0.3), fenceMat);
    sf.position.set(0, 1.9, 60); g.add(sf);

    // East Fence
    const ef = new THREE.Mesh(new THREE.BoxGeometry(0.3, 3.8, 140), fenceMat);
    ef.position.set(115, 1.9, -10); g.add(ef);

    // West Fence
    const wf1 = new THREE.Mesh(new THREE.BoxGeometry(0.3, 3.8, 100), fenceMat);
    wf1.position.set(-120, 1.9, -30); g.add(wf1);

    const wf2 = new THREE.Mesh(new THREE.BoxGeometry(0.3, 3.8, 20), fenceMat);
    wf2.position.set(-120, 1.9, 50); g.add(wf2);

    // Cột cổng thép tại 3 vị trí cổng
    [{x: -75, z: -80}, {x: -55, z: -80}, {x: 25, z: -80}, {x: 45, z: -80}, {x: -120, z: 25}, {x: -120, z: 45}].forEach(p => {
      const pole = new THREE.Mesh(gatePoleGeo, fenceMat);
      pole.position.set(p.x, 4, p.z); g.add(pole);
    });
  }

  buildRoof() {
    const g = this.groups.roof;
    const roofGeo = new THREE.BoxGeometry(175, 0.8, 98);
    const roofMat = new THREE.MeshStandardMaterial({ color: 0x1e293b, metalness: 0.5, roughness: 0.4, transparent: true, opacity: 0.25 });
    const roof = new THREE.Mesh(roofGeo, roofMat);
    roof.position.set(0, 37, 0);
    g.add(roof);
  }

  // 3D Optical Fiber Backbone Lines & Cable Trays
  buildCableTrayTrunking() {
    const g = this.groups.cableTrays;
    const trayMat = new THREE.MeshStandardMaterial({ color: 0x64748b, metalness: 0.8, roughness: 0.3 });

    // Main 1F Cable Tray Trunk
    const tray1Geo = new THREE.BoxGeometry(160, 0.5, 2.5);
    const tray1 = new THREE.Mesh(tray1Geo, trayMat);
    tray1.position.set(0, 11.5, 0);
    g.add(tray1);

    // 2F Cable Tray Trunk
    const tray2Geo = new THREE.BoxGeometry(70, 0.5, 2.5);
    const tray2 = new THREE.Mesh(tray2Geo, trayMat);
    tray2.position.set(-50, 33.5, -25);
    g.add(tray2);

    // Vertical Riser Shaft Conduit (Từ RACK MAIN 2F xuống Tầng 1)
    const riserGeo = new THREE.BoxGeometry(2.0, 32, 2.0);
    const riser = new THREE.Mesh(riserGeo, trayMat);
    riser.position.set(-70, 16, -32);
    g.add(riser);

    // Glowing Optical Fiber Backbone Lines (Từ RACK MAIN 42U cấp đến 9 tủ phụ)
    const fiberMat = new THREE.LineDashedMaterial({ color: 0x22d3ee, dashSize: 3, gapSize: 1.5, linewidth: 2.5 });
    const rackTargets = [
      new THREE.Vector3(0, 2, 35),     // RACK_01 (1F Lắp Ráp / VP Xưởng 3)
      new THREE.Vector3(-35, 2, -35),  // RACK_02 (1F Điều Khiển Mixer)
      new THREE.Vector3(65, 2, -35),   // RACK_03 (1F QC / PCCC)
      new THREE.Vector3(-10, 26, 28),  // RACK_04 (2F Module Working)
      new THREE.Vector3(50, 2, -60),   // RACK_05 (E-Parking Nhà Xe)
      new THREE.Vector3(-65, 2, -75),  // RACK_06 (Bảo Vệ 1 - Cổng Chính)
      new THREE.Vector3(-105, 2, 35),  // RACK_07 (Bảo Vệ 2 - Cổng Logistics)
      new THREE.Vector3(35, 2, -75),   // RACK_08 (Bảo Vệ 3 - Cổng Xe Máy)
      new THREE.Vector3(-95, 2, -15)   // RACK_09 (Trạm Tiện Ích)
    ];

    rackTargets.forEach(pt => {
      const points = [
        new THREE.Vector3(-72, 25.5, -32),
        new THREE.Vector3(pt.x, 25.5, -32),
        new THREE.Vector3(pt.x, pt.y, pt.z)
      ];
      const geo = new THREE.BufferGeometry().setFromPoints(points);
      const line = new THREE.Line(geo, fiberMat);
      line.computeLineDistances();
      g.add(line);
    });
  }

  // ĐỒNG BỘ TOÀN BỘ CÁC THIẾT BỊ ĐƯỢC CHỈ ĐỊNH (RACKS, WIFI, TA/AC, OUTLETS)
  syncAllAssets(data) {
    while (this.groups.beacons.children.length > 0) this.groups.beacons.remove(this.groups.beacons.children[0]);
    while (this.groups.racks.children.length > 0) this.groups.racks.remove(this.groups.racks.children[0]);
    while (this.groups.wifi.children.length > 0) this.groups.wifi.remove(this.groups.wifi.children[0]);
    while (this.groups.outlets.children.length > 0) this.groups.outlets.remove(this.groups.outlets.children[0]);
    this.allDevices.clear();

    // 1. TA & AC Devices (Doors, TA machines, Flap Barriers, USB station)
    (data.devices || []).forEach(dev => {
      const pos = this.calculateDevice3DPosition(dev);
      const beaconObj = this.createFaceIdBeacon(dev, pos);
      this.groups.beacons.add(beaconObj.group);
      this.allDevices.set(dev.id, { group: beaconObj.group, ring: beaconObj.ring, orb: beaconObj.orb, data: dev, type: dev.type, pos3D: pos });
    });

    // 2. IT Racks
    (data.itRacks || []).forEach(rack => {
      const pos = this.calculateRack3DPosition(rack);
      const rackObj = this.create3DRackCabinet(rack, pos);
      this.groups.racks.add(rackObj.group);
      this.allDevices.set(rack.id, { group: rackObj.group, data: rack, type: 'IT_RACK', pos3D: pos });
    });

    // 3. Wi-Fi Access Points
    (data.wifiAccessPoints || []).forEach(ap => {
      const pos = this.calculateWifi3DPosition(ap);
      const apObj = this.create3DWifiMesh(ap, pos);
      this.groups.wifi.add(apObj.group);
      this.allDevices.set(ap.id, { group: apObj.group, data: ap, type: 'WIFI', pos3D: pos });
    });

    // 4. Network LAN & TEL Outlets
    (data.networkOutlets || []).forEach(out => {
      const pos = this.calculateOutlet3DPosition(out);
      const outObj = this.create3DOutletMesh(out, pos);
      this.groups.outlets.add(outObj.group);
      this.allDevices.set(out.id, { group: outObj.group, data: out, type: 'OUTLET', pos3D: pos });
    });
  }

  // TÍNH TOÁN TỌA ĐỘ 3D
  calculateDevice3DPosition(dev) {
    const floor = dev.floor;
    if (floor === '1F') {
      let x = (dev.x - 50) * 1.5;
      let z = (dev.y - 50) * 0.9 - 10;
      return new THREE.Vector3(x, 1.8, z);
    } else if (floor === '1.5F') {
      let x = -65 + (dev.x - 50) * 0.5;
      let z = -30 + (dev.y - 50) * 0.5;
      return new THREE.Vector3(x, 15.8, z);
    } else if (floor === '2F') {
      let x = (dev.x - 50) * 1.2 - 20;
      let z = (dev.y - 50) * 0.9 - 10;
      return new THREE.Vector3(x, 25.8, z);
    } else if (floor === 'PARKING') {
      let idx = parseInt(dev.id.replace('AC-', '')) - 10;
      if (isNaN(idx) || idx < 0) idx = 0;
      return new THREE.Vector3(22 + idx * 6.2, 2.8, -60);
    }
    return new THREE.Vector3(0, 2, 0);
  }

  calculateRack3DPosition(rack) {
    if (rack.id === 'RACK_MAIN') return new THREE.Vector3(-72, 24.5, -32);
    if (rack.id === 'RACK_PA') return new THREE.Vector3(-68, 24.5, -32);
    if (rack.id === 'RACK_01') return new THREE.Vector3(0, 0.5, 35);
    if (rack.id === 'RACK_02') return new THREE.Vector3(-35, 0.5, -35);
    if (rack.id === 'RACK_03') return new THREE.Vector3(65, 0.5, -35);
    if (rack.id === 'RACK_04') return new THREE.Vector3(-10, 24.5, 28);
    if (rack.id === 'RACK_05') return new THREE.Vector3(50, 0.5, -60);
    if (rack.id === 'RACK_06') return new THREE.Vector3(-65, 0.5, -75);
    if (rack.id === 'RACK_07') return new THREE.Vector3(-105, 0.5, 35);
    if (rack.id === 'RACK_08') return new THREE.Vector3(35, 0.5, -75);
    if (rack.id === 'RACK_09') return new THREE.Vector3(-95, 0.5, -15);
    return new THREE.Vector3(0, 1, 0);
  }

  calculateWifi3DPosition(ap) {
    const floor = ap.floor;
    let y = 11.8;
    if (floor === '1.5F') y = 22.5;
    if (floor === '2F') y = 34.8;
    if (floor === 'PARKING') y = 8.5;

    let x = (ap.x - 50) * 1.5;
    let z = (ap.y - 50) * 0.9 - 10;
    if (floor === 'PARKING') z = -60;
    return new THREE.Vector3(x, y, z);
  }

  calculateOutlet3DPosition(out) {
    const floor = out.floor;
    let y = 0.5;
    if (floor === '1.5F') y = 14.5;
    if (floor === '2F') y = 24.5;

    let x = (out.x - 50) * 1.5;
    let z = (out.y - 50) * 0.9 - 10;
    if (floor === '1.5F') {
      x = -65 + (out.x - 50) * 0.5;
      z = -30 + (out.y - 50) * 0.5;
    } else if (floor === '2F') {
      x = (out.x - 50) * 1.2 - 20;
      z = (out.y - 50) * 0.9 - 10;
    } else if (floor === 'PARKING') {
      if (out.id.includes('GH1')) { x = -65; z = -73; }
      else if (out.id.includes('GH2')) { x = -105; z = 33; }
      else { x = 35; z = -73; }
    }
    return new THREE.Vector3(x, y, z);
  }

  // 1. Face ID / Access Control Beacon
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

  // 3. 3D Wi-Fi 6 Access Point
  create3DWifiMesh(ap, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    const apGeo = new THREE.CylinderGeometry(1.6, 1.8, 0.5, 24);
    const apMat = new THREE.MeshStandardMaterial({ color: 0xffffff, metalness: 0.4, roughness: 0.3 });
    const apMesh = new THREE.Mesh(apGeo, apMat);
    group.add(apMesh);

    const ledGeo = new THREE.CylinderGeometry(0.5, 0.5, 0.55, 16);
    const ledMat = new THREE.MeshBasicMaterial({ color: 0x3b82f6 });
    const led = new THREE.Mesh(ledGeo, ledMat);
    group.add(led);

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

  // 4. 3D Network LAN / TEL Outlet Mesh
  create3DOutletMesh(out, pos) {
    const group = new THREE.Group();
    group.position.copy(pos);

    const isFloor = out.type === 'OUTLET_FLOOR';
    const isTel = out.type === 'OUTLET_TEL';
    const outColor = isFloor ? 0xf59e0b : (isTel ? 0x10b981 : 0x06b6d4);

    if (isFloor) {
      // Hộp đồng âm sàn nắp mở kim loại
      const baseGeo = new THREE.BoxGeometry(2.6, 0.4, 2.6);
      const baseMat = new THREE.MeshStandardMaterial({ color: 0xb45309, metalness: 0.85, roughness: 0.25 });
      const baseMesh = new THREE.Mesh(baseGeo, baseMat);
      baseMesh.position.y = 0.2;
      group.add(baseMesh);

      const lidGeo = new THREE.BoxGeometry(2.2, 0.15, 2.2);
      const lidMat = new THREE.MeshStandardMaterial({ color: 0xd97706, metalness: 0.9, roughness: 0.2 });
      const lidMesh = new THREE.Mesh(lidGeo, lidMat);
      lidMesh.position.set(0, 0.45, 0);
      group.add(lidMesh);

      // Cụm cổng RJ45 phát sáng nhẹ
      const portGeo = new THREE.BoxGeometry(1.6, 0.1, 0.8);
      const portMat = new THREE.MeshBasicMaterial({ color: 0x22d3ee });
      const portMesh = new THREE.Mesh(portGeo, portMat);
      portMesh.position.set(0, 0.55, 0);
      group.add(portMesh);

      baseMesh.userData = { isDevice: true, deviceId: out.id, deviceData: out };
    } else {
      // Mặt nạ âm tường chuẩn Modun Faceplate
      const plateGeo = new THREE.BoxGeometry(1.8, 1.8, 0.3);
      const plateMat = new THREE.MeshStandardMaterial({ color: 0xf8fafc, roughness: 0.3, metalness: 0.2 });
      const plateMesh = new THREE.Mesh(plateGeo, plateMat);
      plateMesh.position.y = 1.0;
      group.add(plateMesh);

      const jackGeo = new THREE.BoxGeometry(1.0, 0.5, 0.1);
      const jackMat = new THREE.MeshBasicMaterial({ color: isTel ? 0x10b981 : 0x06b6d4 });
      const jackMesh = new THREE.Mesh(jackGeo, jackMat);
      jackMesh.position.set(0, 1.0, 0.2);
      group.add(jackMesh);

      plateMesh.userData = { isDevice: true, deviceId: out.id, deviceData: out };
    }

    const tagSprite = this.createFloatingTextSprite(`${out.code}`, outColor);
    tagSprite.position.set(0, 2.6, 0);
    tagSprite.scale.set(11, 2.7, 1);
    group.add(tagSprite);

    return { group };
  }

  // BỘ LỌC LỚP THIẾT BỊ (ALL, TA_AC, IT_RACK, WIFI, OUTLETS, BARRIER)
  setDeviceLayerFilter(layer) {
    this.activeLayer = layer;

    this.groups.racks.visible = (layer === 'ALL' || layer === 'IT_RACK');
    this.groups.wifi.visible = (layer === 'ALL' || layer === 'WIFI');
    this.groups.outlets.visible = (layer === 'ALL' || layer === 'OUTLET' || layer === 'OUTLETS');
    this.groups.cableTrays.visible = (layer === 'ALL' || layer === 'IT_RACK' || layer === 'OUTLETS');

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
      ...this.groups.wifi.children,
      ...this.groups.outlets.children
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
      ...this.groups.wifi.children,
      ...this.groups.outlets.children
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
    const camTarget = new THREE.Vector3(targetPos.x - 20, targetPos.y + 18, targetPos.z - 25);
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
      this.smoothMoveCamera(new THREE.Vector3(0, 60, -90), new THREE.Vector3(0, 5, 0), 900);
    } else if (floor === '1.5F') {
      this.smoothMoveCamera(new THREE.Vector3(-65, 40, -80), new THREE.Vector3(-65, 16, -30), 900);
    } else if (floor === '2F') {
      this.smoothMoveCamera(new THREE.Vector3(-70, 60, -80), new THREE.Vector3(-50, 26, -10), 900);
    } else if (floor === 'PARKING') {
      this.smoothMoveCamera(new THREE.Vector3(30, 40, -110), new THREE.Vector3(35, 2, -65), 900);
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
    const opacity = this.isXRay ? 0.28 : 0.88;

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

    if (this.container && this.container.offsetParent === null) return;

    const delta = this.clock.getDelta();
    const time = this.clock.getElapsedTime();

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
