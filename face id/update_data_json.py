import json

with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Sheet 42/03 Official Product Quantities Summary
data['drawingInfo'] = {
    'project': 'VINATECH VINA HƯNG YÊN FACTORY',
    'drawingNo': 'ELV-42/03',
    'version': 'v5.2 (2026.06.15)',
    'designer': 'DOUL ASIA CO., LTD',
    'contractor': 'WORLDSTAR INTERNATIONAL J.S.C',
    'summary': {
        'networkPbx': [
            {'no': 1, 'item': 'Firewall Router Gateway (Fortinet FortiGate 100E)', 'unit': 'EA', 'qty': 1, 'model': 'Fortinet FortiGate 100E HA Ready'},
            {'no': 2, 'item': 'L3 Switch 24-Port (Core Switch Trung Tâm)', 'unit': 'EA', 'qty': 1, 'model': 'Cisco/HP 24-Port GbE + 4 SFP+ Uplink'},
            {'no': 3, 'item': 'L2 Switch 48-Port (Switch Phân Phối Tầng)', 'unit': 'EA', 'qty': 3, 'model': '48-Port 10/100/1000Mbps Managed'},
            {'no': 4, 'item': 'L2 Switch 24-Port', 'unit': 'EA', 'qty': 2, 'model': '24-Port Gigabit Managed'},
            {'no': 5, 'item': 'L2 Switch 08-Port', 'unit': 'EA', 'qty': 5, 'model': '8-Port Gigabit Desktop/Rack'},
            {'no': 6, 'item': 'Access Point (Wi-Fi 6 AP Doanh Nghiệp)', 'unit': 'EA', 'qty': 8, 'model': 'Dual-Band Gigabit Wi-Fi 6 AX3000'},
            {'no': 7, 'item': 'Cable Management 1U/2U (Thanh Quản Lý Cáp)', 'unit': 'EA', 'qty': 14, 'model': 'AMP Netconnect 19 inch 1U'},
            {'no': 8, 'item': '02 LAN, Wall Outlet (Ổ Cắm Mạng Đôi Âm Tường)', 'unit': 'SET', 'qty': 4, 'model': 'Mặt 2 Port + Nhân Cat6 UTP'},
            {'no': 9, 'item': '01 LAN, 01 TEL, Wall Outlet (Ổ Mạng + Thoại)', 'unit': 'SET', 'qty': 3, 'model': 'Mặt 2 Port RJ45 + RJ11'},
            {'no': 10, 'item': '06 LAN, Wall Outlet (Cụm Bàn Làm Việc 6 Port)', 'unit': 'SET', 'qty': 58, 'model': 'Hộp ổ cắm bàn văn phòng 6 Port Cat6'},
            {'no': 11, 'item': '04 LAN, Wall Outlet (Cụm Bàn Làm Việc 4 Port)', 'unit': 'SET', 'qty': 6, 'model': 'Hộp ổ cắm bàn văn phòng 4 Port Cat6'},
            {'no': 12, 'item': '01 LAN, Wall Outlet (Ổ Cắm Mạng Đơn Âm Tường)', 'unit': 'SET', 'qty': 22, 'model': 'Mặt 1 Port RJ45 Cat6'},
            {'no': 13, 'item': '01 LAN, Floor Outlet (Ổ Cắm Mạng Âm Sàn)', 'unit': 'SET', 'qty': 2, 'model': 'Hộp ổ cắm âm sàn đồng kim loại'},
            {'no': 14, 'item': 'Media Converter (Bộ Chuyển Đổi Quang - Điện)', 'unit': 'EA', 'qty': 9, 'model': '1000Base-FX to 1000Base-T'},
            {'no': 15, 'item': 'ODF Hộp Phối Quang (Fiber Patch Panel)', 'unit': 'EA', 'qty': 2, 'model': 'ODF 24/48-Core SC/LC Rackmount'},
            {'no': 16, 'item': 'UPS Bộ Lưu Điện Dự Phòng (Online UPS)', 'unit': 'EA', 'qty': 9, 'model': '10kW / 6kVA / 1kVA Pure Sine Wave'},
            {'no': 17, 'item': 'Rack Cabinet (Hệ Thống Tủ RACK IT)', 'unit': 'EA', 'qty': 10, 'model': '42U D1000, 27U D800, 10U D600, Outside Box'},
            {'no': 18, 'item': 'Tổng Đài IP PBX Server', 'unit': 'EA', 'qty': 1, 'model': 'IP PBX Server 100 Extensions'},
            {'no': 19, 'item': 'Điện Thoại IP Phone (Bàn Văn Phòng)', 'unit': 'EA', 'qty': 23, 'model': 'HD Voice IP Phone PoE'}
        ],
        'cctv': [
            {'no': 1, 'item': 'IP Bullet Outdoor Camera (Camera Thân Ngoài Trời)', 'unit': 'EA', 'qty': 30, 'model': 'Hikvision 4MP IR 50m IP67 IK10'},
            {'no': 2, 'item': 'IP Dome Indoor Camera (Camera Bán Cầu Trong Nhà)', 'unit': 'EA', 'qty': 48, 'model': 'Hikvision 4MP IR 30m WDR'},
            {'no': 3, 'item': 'IP Bullet Flame Outdoor (Camera Cảm Biến Lửa/Nhiệt)', 'unit': 'EA', 'qty': 2, 'model': 'Thermal Fire Detection chuyên dụng PCCC'},
            {'no': 4, 'item': 'IP Bullet Explosion-Proof (Camera Chống Cháy Nổ)', 'unit': 'EA', 'qty': 1, 'model': 'ATEX/IECEx Zone 1/2 Vỏ Thép Chống Nổ'},
            {'no': 5, 'item': 'NVR Đầu Ghi Hình Mạng HikCentral (64 Ch)', 'unit': 'EA', 'qty': 2, 'model': '64-Channel 4K NVR 8 SATA RAID'},
            {'no': 6, 'item': 'PC Máy Trạm & 3 Màn Hình Giám Sát', 'unit': 'SET', 'qty': 1, 'model': 'PC Client Core i7 + 3 Màn Hình 43 inch'},
            {'no': 7, 'item': 'L2 Main Switch 24-Port (Core Camera)', 'unit': 'EA', 'qty': 1, 'model': '24-Port GbE + 4 SFP Uplink'},
            {'no': 8, 'item': 'L2 Switch PoE 16-Port', 'unit': 'EA', 'qty': 4, 'model': 'PoE+ 802.3at 250W Managed'},
            {'no': 9, 'item': 'L2 Switch PoE 08-Port', 'unit': 'EA', 'qty': 7, 'model': 'PoE+ 802.3af/at 120W'},
            {'no': 10, 'item': 'Camera Pole (Cột Thép Treo Camera)', 'unit': 'EA', 'qty': 11, 'model': 'Cột thép mạ kẽm nhúng nóng 4m - 6m'},
            {'no': 11, 'item': 'Outside Cabinet (Tủ Kỹ Thuật Ngoài Trời)', 'unit': 'EA', 'qty': 1, 'model': 'Tủ kỹ thuật chống nước IP66'}
        ],
        'taAc': [
            {'no': 1, 'item': 'Máy Chấm Công Khuôn Mặt Time Attendance (TA)', 'unit': 'EA', 'qty': 5, 'model': 'Hikvision DS-K1T671MF (Face + Card + Finger)'},
            {'no': 2, 'item': 'Đầu Đọc Kiểm Soát Cửa Access Control (AC)', 'unit': 'EA', 'qty': 16, 'model': 'Face ID Terminal + Mifare + Khóa Từ'},
            {'no': 3, 'item': 'Cổng Phân Làn Flap Barrier (Flapgate)', 'unit': 'EA', 'qty': 6, 'model': '10 Làn Tự Động Nhà Xe (5 Vào + 5 Ra)'},
            {'no': 4, 'item': 'Khóa Điện Từ & Dropbolt (Doorlock)', 'unit': 'EA', 'qty': 6, 'model': 'Khóa từ 600lbs + Khóa chốt rơi Fail-Safe'},
            {'no': 5, 'item': 'Nút Exit & Đập Kính Khẩn Cấp (Exit Button)', 'unit': 'EA', 'qty': 6, 'model': 'Nút cảm ứng không chạm + Breakglass'},
            {'no': 6, 'item': 'Trạm Đăng Ký USB (Faces sample device)', 'unit': 'EA', 'qty': 1, 'model': 'USB Desktop Enrollment Reader'},
            {'no': 7, 'item': 'Hàng Rào Inox Dẫn Làn (Inox Fence)', 'unit': 'SET', 'qty': 2, 'model': 'Inox 304 tiêu chuẩn phân luồng nhà xe'},
            {'no': 8, 'item': 'PC Quản Trị Hệ Thống HikCentral', 'unit': 'EA', 'qty': 1, 'model': 'Server Management Workstation Client'},
            {'no': 9, 'item': 'L2 Switch PoE 16-Port & 08-Port', 'unit': 'EA', 'qty': 3, 'model': 'Switch mạng cho cửa & barrier'}
        ],
        'pa': [
            {'no': 1, 'item': 'Loa Âm Trần (Ceiling Speaker)', 'unit': 'EA', 'qty': 56, 'model': 'TOA / Bosch 6W - 10W 100V Line'},
            {'no': 2, 'item': 'Loa Hộp Gắn Tường (Wall Speaker)', 'unit': 'EA', 'qty': 36, 'model': 'TOA / Bosch 15W - 30W 100V Line'},
            {'no': 3, 'item': 'Loa Còi Phóng Thanh Ngoài Trời (Horn Speaker)', 'unit': 'EA', 'qty': 4, 'model': 'TOA 30W - 50W Chống Nước IP65'},
            {'no': 4, 'item': 'Sound Timer (Bộ Định Giờ Phát Chuông Tự Động)', 'unit': 'EA', 'qty': 1, 'model': 'Lập trình chuông ca, giờ nghỉ tự động'},
            {'no': 5, 'item': 'CD / Media Player (Đầu Phát Nhạc Nền BGM)', 'unit': 'EA', 'qty': 1, 'model': 'USB / Bluetooth / FM Media Tuner'},
            {'no': 6, 'item': 'Amplifier & Extension (Bộ Tăng Âm Trung Tâm)', 'unit': 'EA', 'qty': 2, 'model': 'Power Amplifier 1000W 100V Line'},
            {'no': 7, 'item': 'Remote Microphone (Micro Gọi Thông Báo)', 'unit': 'EA', 'qty': 1, 'model': 'Bàn gọi chọn 16 vùng zone độc lập'},
            {'no': 8, 'item': 'PA Rack Cabinet (Tủ RACK Âm Thanh)', 'unit': 'EA', 'qty': 1, 'model': 'RACK-27U D800 (P. IT Server 304)'}
        ]
    }
}

# Full 10 RACK Cabinets from Sheet 42/11 & 42/12
data['itRacks'] = [
    {
        'id': 'RACK_MAIN',
        'code': 'RACK-MAIN-42U',
        'name': 'Tủ RACK IT Server Trung Tâm 42U (2F)',
        'nameEn': 'Main IT Server Rack 42U',
        'floor': '2F',
        'floorName': 'Tầng 2 Nhà Xưởng',
        'room': 'Phòng IT & Server Room (304)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Server Trung Tâm 42U',
        'icon': '🖥️',
        'equipment': ['Firewall FortiGate 100E', 'L3 Core Switch 24-Port', 'L2 Switch 48-Port', 'NVR HikCentral 64Ch', 'UPS Rackmount 6kVA', 'ODF 52-Port', 'IP PBX Server'],
        'ipAddress': '192.168.184.250',
        'power': '220V Dual AC Feed + Online UPS 6kVA',
        'status': 'online',
        'temp': '21.5°C',
        'x': 45,
        'y': 30
    },
    {
        'id': 'RACK_PA',
        'code': 'RACK-PA-27U',
        'name': 'Tủ RACK Âm Thanh PA 27U (2F)',
        'nameEn': '2F Public Address Rack 27U',
        'floor': '2F',
        'floorName': 'Tầng 2 Nhà Xưởng',
        'room': 'Phòng IT & Server Room (304)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Âm Thanh PA 27U',
        'icon': '📢',
        'equipment': ['Amplifier 1000W', 'Amplifier Extension', 'Sound Timer Tự Động', 'CD/MP3 Player BGM', 'Monitor Panel', 'ODF 4-Port'],
        'ipAddress': '192.168.184.240',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '22.0°C',
        'x': 48,
        'y': 30
    },
    {
        'id': 'RACK_01',
        'code': 'RACK-01-1F',
        'name': 'Tủ Phân Phối Sảnh & Showroom (10U)',
        'nameEn': '1F Floor Rack 01 (Lobby)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Sảnh Chính (101) / Trục Cáp Riser A',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Sàn Tầng 1 (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch 48-Port PoE', 'L2 Switch PoE 8-Port', 'ODF 8-Port', 'Bộ Điều Khiển Cửa AC-01'],
        'ipAddress': '192.168.184.201',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '24.0°C',
        'x': 86,
        'y': 55
    },
    {
        'id': 'RACK_02',
        'code': 'RACK-02-1F',
        'name': 'Tủ Phân Phối Khu Sản Xuất (10U)',
        'nameEn': '1F Floor Rack 02 (Production)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Hành Lang Kỹ Thuật / P. 128',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Sàn Sản Xuất (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch 8-Port', 'L2 Switch PoE 16-Port', 'ODF 8-Port', 'Bộ Điều Khiển Cửa AC-02, AC-03'],
        'ipAddress': '192.168.184.202',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '25.2°C',
        'x': 55,
        'y': 60
    },
    {
        'id': 'RACK_03',
        'code': 'RACK-03-1F',
        'name': 'Tủ Phân Phối Kho 104 & Dock 105 (10U)',
        'nameEn': '1F Warehouse Rack 03',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Kho Nguyên Vật Liệu 1 (104)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Sàn Kho Bãi (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch PoE 16-Port', 'ODF 12-Port', 'Chống Sét Lan Truyền Dintek'],
        'ipAddress': '192.168.184.203',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '26.0°C',
        'x': 20,
        'y': 50
    },
    {
        'id': 'RACK_04',
        'code': 'RACK-04-2F',
        'name': 'Tủ Phân Phối Văn Phòng 2F (10U)',
        'nameEn': '2F Office Rack 04',
        'floor': '2F',
        'floorName': 'Tầng 2 Nhà Xưởng',
        'room': 'Khối Văn Phòng Tổng Hợp (302)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Sàn Văn Phòng (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch 48-Port Gigabit', 'L2 Switch PoE 16-Port', 'ODF 8-Port', 'Patch Panel Cat6'],
        'ipAddress': '192.168.184.204',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '23.5°C',
        'x': 73,
        'y': 45
    },
    {
        'id': 'RACK_05',
        'code': 'RACK-05-1F',
        'name': 'Tủ Phân Phối Căn Tin & Tiện Ích (10U)',
        'nameEn': '1F Utility Rack 05',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Khu Nghỉ Ca & Căn Tin (115A)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Sàn Căn Tin (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch 8-Port', 'L2 Switch PoE 16-Port', 'ODF 16-Port'],
        'ipAddress': '192.168.184.205',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '24.8°C',
        'x': 50,
        'y': 80
    },
    {
        'id': 'RACK_06',
        'code': 'RACK-06-GUARD1',
        'name': 'Tủ Mạng Nhà Bảo Vệ Cổng Chính (10U)',
        'nameEn': 'Guardhouse 1 Rack 06',
        'floor': 'PARKING',
        'floorName': 'Khu Nhà Xe / Cổng Chính',
        'room': 'Nhà Bảo Vệ 1 (Cổng Chính)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Mạng Cổng Chính (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch 8-Port', 'L2 Switch PoE 8-Port', 'ODF 8-Port', 'Màn Hình CCTV 43 inch'],
        'ipAddress': '192.168.184.206',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '27.0°C',
        'x': 35,
        'y': 72
    },
    {
        'id': 'RACK_08',
        'code': 'RACK-08-PARK',
        'name': 'Tủ Điều Khiển Nhà Xe E-Parking (10U)',
        'nameEn': 'E-Parking Barrier Rack 08',
        'floor': 'PARKING',
        'floorName': 'Khu Nhà Xe / Cổng Chính',
        'room': 'Nhà Xe E-Parking (Guardhouse 3)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Điều Khiển Barrier (10U)',
        'icon': '🗄️',
        'equipment': ['L2 Switch PoE 8-Port', 'ODF 8-Port', 'Bộ Điều Khiển 10 Cổng Barrier', 'Chống Sét Mạng'],
        'ipAddress': '192.168.184.208',
        'power': '220V Solar Inverter Backup',
        'status': 'online',
        'temp': '28.1°C',
        'x': -25,
        'y': 60
    },
    {
        'id': 'BOX_OUTSIDE',
        'code': 'BOX-01-OUTSIDE',
        'name': 'Tủ Kỹ Thuật Camera Ngoài Trời (IP66)',
        'nameEn': 'Outside Camera Weatherproof Box',
        'floor': 'PARKING',
        'floorName': 'Khuôn Viên Ngoài Trời',
        'room': 'Trục Cột Camera Chu Vi',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Kỹ Thuật Ngoài Trời',
        'icon': '⚡',
        'equipment': ['L2 Switch PoE 16-Port Industrial', 'Bộ Nguồn DC12V/24V', 'Chống Sét Lan Truyền'],
        'ipAddress': '192.168.184.210',
        'power': '220V Công Nghiệp',
        'status': 'online',
        'temp': '29.0°C',
        'x': 85,
        'y': 40
    }
]

# 8 Wi-Fi 6 Enterprise Access Points
data['wifiAccessPoints'] = [
    {'id': 'AP-01', 'code': 'AP-01', 'name': 'Wi-Fi AP Sảnh Chính & Showroom', 'floor': '1F', 'room': 'Showroom (101)', 'ipAddress': '192.168.184.71', 'status': 'online', 'x': 86, 'y': 25, 'clients': 18},
    {'id': 'AP-02', 'code': 'AP-02', 'name': 'Wi-Fi AP Căn Tin & Khu Nghỉ Ca', 'floor': '1F', 'room': 'Căn Tin (115A)', 'ipAddress': '192.168.184.72', 'status': 'online', 'x': 55, 'y': 80, 'clients': 42},
    {'id': 'AP-03', 'code': 'AP-03', 'name': 'Wi-Fi AP Xưởng Sản Xuất Khu A', 'floor': '1F', 'room': 'Xưởng Supercapacitor', 'ipAddress': '192.168.184.73', 'status': 'online', 'x': 25, 'y': 45, 'clients': 12},
    {'id': 'AP-04', 'code': 'AP-04', 'name': 'Wi-Fi AP Xưởng Sản Xuất Khu B', 'floor': '1F', 'room': 'Xưởng Supercapacitor', 'ipAddress': '192.168.184.74', 'status': 'online', 'x': 60, 'y': 45, 'clients': 15},
    {'id': 'AP-05', 'code': 'AP-05', 'name': 'Wi-Fi AP Khối Văn Phòng 1.5F', 'floor': '1.5F', 'room': 'Văn Phòng 201/202', 'ipAddress': '192.168.184.75', 'status': 'online', 'x': 60, 'y': 50, 'clients': 24},
    {'id': 'AP-06', 'code': 'AP-06', 'name': 'Wi-Fi AP Khối Văn Phòng 2F Khu A', 'floor': '2F', 'room': 'Văn Phòng 302', 'ipAddress': '192.168.184.76', 'status': 'online', 'x': 70, 'y': 35, 'clients': 36},
    {'id': 'AP-07', 'code': 'AP-07', 'name': 'Wi-Fi AP Khối Văn Phòng 2F Khu B', 'floor': '2F', 'room': 'Văn Phòng 302 & P. Họp', 'ipAddress': '192.168.184.77', 'status': 'online', 'x': 80, 'y': 70, 'clients': 28},
    {'id': 'AP-08', 'code': 'AP-08', 'name': 'Wi-Fi AP Khu Nhà Xe & Bảo Vệ', 'floor': 'PARKING', 'room': 'Nhà Xe E-Parking', 'ipAddress': '192.168.184.78', 'status': 'online', 'x': 40, 'y': 50, 'clients': 19}
]

# PA Audio Speakers Zones (56 Ceiling + 36 Wall + 4 Horn = 96 Speakers)
data['paSpeakers'] = [
    {'id': 'SPK-Z1', 'code': 'PA-Z1', 'name': 'Cụm Loa Âm Trần Sảnh & Showroom (8 Loa)', 'floor': '1F', 'type': 'CEILING', 'qty': 8, 'zone': 'Vùng 1 (Sảnh & Showroom 101)', 'status': 'standby', 'x': 86, 'y': 25},
    {'id': 'SPK-Z2', 'code': 'PA-Z2', 'name': 'Cụm Loa Hộp Gắn Tường Xưởng Sản Xuất (36 Loa)', 'floor': '1F', 'type': 'WALL', 'qty': 36, 'zone': 'Vùng 2 (Xưởng Sản Xuất Chính)', 'status': 'standby', 'x': 35, 'y': 50},
    {'id': 'SPK-Z3', 'code': 'PA-Z3', 'name': 'Cụm Loa Âm Trần Căn Tin & Nghỉ Ca (16 Loa)', 'floor': '1F', 'type': 'CEILING', 'qty': 16, 'zone': 'Vùng 3 (Căn Tin 115A & Locker 136)', 'status': 'standby', 'x': 55, 'y': 80},
    {'id': 'SPK-Z4', 'code': 'PA-Z4', 'name': 'Cụm Loa Âm Trần Khối Văn Phòng 1.5F & 2F (32 Loa)', 'floor': '2F', 'type': 'CEILING', 'qty': 32, 'zone': 'Vùng 4 (Khối Văn Phòng 201, 302, 303)', 'status': 'standby', 'x': 73, 'y': 50},
    {'id': 'SPK-Z5', 'code': 'PA-Z5', 'name': 'Cụm Loa Còi Phóng Thanh Ngoài Trời & Nhà Xe (4 Loa)', 'floor': 'PARKING', 'type': 'HORN', 'qty': 4, 'zone': 'Vùng 5 (Nhà Xe E-Parking & Cổng Bảo Vệ)', 'status': 'standby', 'x': 50, 'y': 30}
]

# CCTV Network expanded with Flame & Explosion-proof
data['cctvCameras'] = [
    { 'id': 'CAM-01', 'code': 'CAM-01', 'name': 'Camera Sảnh Chính Showroom (101)', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Dome 4MP', 'icon': '📹', 'ipAddress': '192.168.184.51', 'status': 'online', 'x': 86, 'y': 25 },
    { 'id': 'CAM-02', 'code': 'CAM-02', 'name': 'Camera Kho Vật Liệu 1 (104)', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Bullet 4MP IR 50m', 'icon': '📹', 'ipAddress': '192.168.184.52', 'status': 'online', 'x': 20, 'y': 80 },
    { 'id': 'CAM-03', 'code': 'CAM-03', 'name': 'Camera Logistic Dock 105', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Bullet 4MP Ngoài Trời', 'icon': '📹', 'ipAddress': '192.168.184.53', 'status': 'online', 'x': 20, 'y': 25 },
    { 'id': 'CAM-04', 'code': 'CAM-04', 'name': 'Camera Dây Chuyền Sản Xuất Chính', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Bullet 4MP Góc Rộng', 'icon': '📹', 'ipAddress': '192.168.184.54', 'status': 'online', 'x': 50, 'y': 50 },
    { 'id': 'CAM-05', 'code': 'CAM-05', 'name': 'Camera P. Điều Khiển Mixer 128', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Dome 4MP Âm Trần', 'icon': '📹', 'ipAddress': '192.168.184.55', 'status': 'online', 'x': 64.5, 'y': 30 },
    { 'id': 'CAM-06', 'code': 'CAM-06', 'name': 'Camera Căn Tin 115A', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Dome 4MP Âm Trần', 'icon': '📹', 'ipAddress': '192.168.184.56', 'status': 'online', 'x': 55, 'y': 85 },
    { 'id': 'CAM-07', 'code': 'CAM-07', 'name': 'Camera Khu Locker & QC 136', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'Camera Dome 4MP', 'icon': '📹', 'ipAddress': '192.168.184.57', 'status': 'online', 'x': 40.5, 'y': 20 },
    { 'id': 'CAM-08', 'code': 'CAM-08', 'name': 'Camera P. IT Server Room 304', 'floor': '2F', 'type': 'CCTV', 'typeLabel': 'Camera Dome An Ninh 360°', 'icon': '📹', 'ipAddress': '192.168.184.58', 'status': 'online', 'x': 45, 'y': 45 },
    { 'id': 'CAM-09', 'code': 'CAM-09', 'name': 'Camera Khối Văn Phòng 2F (302)', 'floor': '2F', 'type': 'CCTV', 'typeLabel': 'Camera Dome 4MP', 'icon': '📹', 'ipAddress': '192.168.184.59', 'status': 'online', 'x': 73, 'y': 70 },
    { 'id': 'CAM-10', 'code': 'CAM-10', 'name': 'Camera Cổng Flap Barrier CHIỀU VÀO', 'floor': 'PARKING', 'type': 'CCTV', 'typeLabel': 'Camera Nhận Diện Khuôn Mặt & Biển Số', 'icon': '📹', 'ipAddress': '192.168.184.60', 'status': 'online', 'x': 30, 'y': 15 },
    { 'id': 'CAM-11', 'code': 'CAM-11', 'name': 'Camera Cổng Flap Barrier CHIỀU RA', 'floor': 'PARKING', 'type': 'CCTV', 'typeLabel': 'Camera Nhận Diện Khuôn Mặt & Biển Số', 'icon': '📹', 'ipAddress': '192.168.184.61', 'status': 'online', 'x': 70, 'y': 15 },
    { 'id': 'CAM-12', 'code': 'CAM-12', 'name': 'Camera Speed Dome PTZ Toàn Cảnh Cổng', 'floor': 'PARKING', 'type': 'CCTV', 'typeLabel': 'Camera Speed Dome PTZ 32x Zoom', 'icon': '📹', 'ipAddress': '192.168.184.62', 'status': 'online', 'x': 90, 'y': 40 },
    { 'id': 'CAM-FLAME-01', 'code': 'CAM-FLAME-01', 'name': 'Camera Cảm Biến Lửa Kho Hóa Chất', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'IP Bullet Flame Outdoor', 'icon': '🔥', 'ipAddress': '192.168.184.63', 'status': 'online', 'x': 15, 'y': 65 },
    { 'id': 'CAM-FLAME-02', 'code': 'CAM-FLAME-02', 'name': 'Camera Cảm Biến Lửa Trạm Biến Áp', 'floor': 'PARKING', 'type': 'CCTV', 'typeLabel': 'IP Bullet Flame Outdoor', 'icon': '🔥', 'ipAddress': '192.168.184.64', 'status': 'online', 'x': 10, 'y': 40 },
    { 'id': 'CAM-EX-01', 'code': 'CAM-EX-01', 'name': 'Camera Chống Cháy Nổ Khu Mixer Sơn', 'floor': '1F', 'type': 'CCTV', 'typeLabel': 'IP Bullet Explosion-Proof', 'icon': '🛡️', 'ipAddress': '192.168.184.65', 'status': 'online', 'x': 60, 'y': 25 }
]

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print('Updated data.json successfully with full drawing ELV catalog and Sheet 42/03 BOQ!')
