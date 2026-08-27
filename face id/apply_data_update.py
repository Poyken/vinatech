import json

# 1. Update data.json with 100% accurate RACK and IT specs from Sheet 42/11, 42/06, 42/07, 42/08, 42/38-43
with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

data['drawingInfo'] = {
    'project': 'VINATECH VINA HƯNG YÊN FACTORY',
    'drawingNo': 'ELV-42/03 to 42/43',
    'version': 'v5.2 (2026.06.15)',
    'designer': 'DOUL ASIA CO., LTD',
    'contractor': 'WORLDSTAR INTERNATIONAL J.S.C',
    'summary': {
        'networkPbx': [
            {'no': 1, 'item': 'Firewall Router Gateway (Fortinet FortiGate 100E)', 'unit': 'EA', 'qty': 1, 'model': 'Fortinet FortiGate 100E HA Ready'},
            {'no': 2, 'item': 'L3 Switch 24-Port (Core Switch Trung Tâm)', 'unit': 'EA', 'qty': 1, 'model': 'Cisco/HP 24-Port GbE + 4 SFP+ Uplink'},
            {'no': 3, 'item': 'L2 Switch 48-Port (Switch Phân Phối Tầng)', 'unit': 'EA', 'qty': 3, 'model': 'Cisco 48-Port 10/100/1000Mbps Managed'},
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
            {'no': 15, 'item': 'ODF Hộp Phối Quang (Fiber Patch Panel)', 'unit': 'EA', 'qty': 2, 'model': 'ODF 52-Port / 8-Port SC/LC Rackmount'},
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
            {'no': 5, 'item': 'NVR Đầu Ghi Hình Mạng HikCentral (64 Ch & 32 Ch)', 'unit': 'EA', 'qty': 2, 'model': '64-Channel + 32-Channel 4K NVR RAID'},
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
            {'no': 4, 'item': 'Sound Timer (Bộ Định Giờ Phát Chuông Tự Động)', 'unit': 'EA', 'qty': 1, 'model': 'Program Timer TT-104B (Lập trình chuông ca, giờ nghỉ)'},
            {'no': 5, 'item': 'CD / Media Player (Đầu Phát Nhạc Nền BGM)', 'unit': 'EA', 'qty': 1, 'model': 'USB / Bluetooth / FM Media Tuner'},
            {'no': 6, 'item': 'Amplifier & Extension (Bộ Tăng Âm Trung Tâm)', 'unit': 'EA', 'qty': 2, 'model': 'Power Amplifier 1000W 100V Line'},
            {'no': 7, 'item': 'Remote Microphone (Micro Gọi Thông Báo)', 'unit': 'EA', 'qty': 1, 'model': 'Bàn gọi chọn vùng zone độc lập'},
            {'no': 8, 'item': 'PA Rack Cabinet (Tủ RACK Âm Thanh)', 'unit': 'EA', 'qty': 1, 'model': 'RACK-27U D800 (P. IT Server 304)'}
        ]
    }
}

# The true 10 RACK Cabinets exactly matched to Sheet 42/11, 42/06, 42/12, 42/15, 42/18, 42/39
data['itRacks'] = [
    {
        'id': 'RACK_MAIN',
        'code': 'RACK-MAIN-42U',
        'name': 'Tủ RACK IT & Server Trung Tâm 42U',
        'nameEn': 'Main IT Server Rack 42U (D1000)',
        'floor': '2F',
        'floorName': 'Tầng 2 Khối Văn Phòng',
        'room': 'Phòng IT & Server Room (304)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Server Trung Tâm 42U',
        'icon': '🖥️',
        'dimensions': '600x1000x2100mm (42U)',
        'equipment': [
            'Firewall Fortinet FortiGate 100E',
            'Core Switch L3 24-Port GbE + 4 SFP+',
            'Switch Phân Phối Cisco L2 48-Port',
            'Switch L2 24-Port',
            'Switch Access Control L2 08-Port',
            'CCTV Main Switch 24-Port + Switch PoE 08-Port',
            'Đầu Ghi NVR HikCentral 64-Channel + 32-Channel RAID',
            'Tổng Đài IP PBX Server (100 Ext)',
            'ODF Cáp Quang 52-Port + ISP ODF 08-Port',
            'Bộ Lưu Điện Online UPS 10kVA'
        ],
        'ipAddress': '192.168.184.250',
        'power': '220V Dual Feed + Online UPS 10kVA',
        'status': 'online',
        'temp': '21.0°C',
        'x': 82,
        'y': 25
    },
    {
        'id': 'RACK_PA',
        'code': 'RACK-PA-27U',
        'name': 'Tủ RACK Âm Thanh PA Trung Tâm 27U',
        'nameEn': 'Public Address Rack 27U (D800)',
        'floor': '2F',
        'floorName': 'Tầng 2 Khối Văn Phòng',
        'room': 'Phòng IT & Server Room (304) — Cạnh RACK MAIN',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Âm Thanh PA 27U',
        'icon': '📢',
        'dimensions': '600x800x1400mm (27U)',
        'equipment': [
            'Program Timer TT-104B (Hẹn Giờ Phát Chuông Tự Động)',
            'CD / Media Player BGM',
            'Main Power Amplifier 1000W 100V Line',
            'Amplifier Extension',
            'Remote Microphone Selector',
            'Monitor Panel & ODF Quang 4-Port'
        ],
        'ipAddress': '192.168.184.240',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '22.0°C',
        'x': 84.5,
        'y': 25
    },
    {
        'id': 'RACK_01',
        'code': 'RACK-01-1F',
        'name': 'Tủ Phân Phối Tầng 1 — Khu Sản Xuất 1 (10U)',
        'nameEn': '1F Production Rack 01 (10U)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Hành Lang Kỹ Thuật gần VP Xưởng 3 (109) & P. Lắp Ráp 1',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Treo Tường Tầng 1 (10U)',
        'icon': '🗄️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 08-Port',
            'Cisco L2 Switch 48-Port',
            'L2 Switch PoE 16-Port (Camera Khu Sản Xuất 1)',
            'L2 Switch 08-Port'
        ],
        'ipAddress': '192.168.184.201',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '24.2°C',
        'x': 48,
        'y': 22
    },
    {
        'id': 'RACK_02',
        'code': 'RACK-02-1F',
        'name': 'Tủ Phân Phối Tầng 1 — Khu Điều Khiển & Định Hình (10U)',
        'nameEn': '1F Control & Formation Rack 02 (10U)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Khu P. Điều Khiển Mixer 1 (128) & P. Định Hình 1 (131)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Treo Tường Tầng 1 (10U)',
        'icon': '🗄️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 08-Port',
            'L2 Switch 08-Port',
            'L2 Switch PoE 16-Port (Camera Khu Mixer & Định Hình)'
        ],
        'ipAddress': '192.168.184.202',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '25.0°C',
        'x': 25,
        'y': 48
    },
    {
        'id': 'RACK_03',
        'code': 'RACK-03-1F',
        'name': 'Tủ Phân Phối Tầng 1 — Khu QC, PCCC & Đóng Gói (10U)',
        'nameEn': '1F QC, Fire & Packing Rack 03 (10U)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Hành Lang gần VP Xưởng 1 (118), QC Room (136) & PCCC 151',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Treo Tường Tầng 1 (10U)',
        'icon': '🗄️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 12-Port',
            'L2 Switch 24-Port',
            'L2 Switch PoE 16-Port',
            'L2 Switch 08-Port'
        ],
        'ipAddress': '192.168.184.203',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '24.5°C',
        'x': 91,
        'y': 58
    },
    {
        'id': 'RACK_04',
        'code': 'RACK-04-2F',
        'name': 'Tủ Phân Phối Tầng 2 — Xưởng Sản Xuất 2F (10U)',
        'nameEn': '2F Production Floor Rack 04 (10U)',
        'floor': '2F',
        'floorName': 'Tầng 2 Nhà Xưởng',
        'room': 'Khu VP Xưởng 2 (313), VP Xưởng 1 (316) & Module Working (311)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Treo Tường Tầng 2 (10U)',
        'icon': '🗄️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 08-Port',
            'Cisco L2 Switch 48-Port',
            'L2 Switch PoE 08-Port (Camera Tầng 2)'
        ],
        'ipAddress': '192.168.184.204',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '23.8°C',
        'x': 42,
        'y': 20
    },
    {
        'id': 'RACK_05',
        'code': 'RACK-05-EPARK',
        'name': 'Tủ Phân Phối Khu Nhà Xe E-Parking (10U)',
        'nameEn': 'E-Parking Distribution Rack 05 (10U)',
        'floor': 'PARKING',
        'floorName': 'Khu Nhà Xe E-Parking',
        'room': 'Nhà Xe E-Parking (Mặt Trước Xưởng)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Treo Tường Nhà Xe (10U)',
        'icon': '🅿️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 16-Port',
            'L2 Switch 16-Port + Switch L2 08-Port',
            'L2 Switch PoE 16-Port (10 Làn Flap Barrier Face ID & Cam Bãi Xe)'
        ],
        'ipAddress': '192.168.184.205',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '27.0°C',
        'x': 52,
        'y': 35
    },
    {
        'id': 'RACK_06',
        'code': 'RACK-06-GH1',
        'name': 'Tủ RACK Nhà Bảo Vệ 1 — Cổng Chính (10U)',
        'nameEn': 'Guardhouse 1 Main Gate Rack 06 (10U)',
        'floor': 'PARKING',
        'floorName': 'Cổng Chính (Main Gate)',
        'room': 'Nhà Bảo Vệ 1 (Cổng Chính Mặt Đường KCN)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Nhà Bảo Vệ 1 (10U)',
        'icon': '🛡️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 08-Port',
            'L2 Switch 08-Port',
            'L2 Switch PoE 08-Port (Camera Nhận Diện Biển Số ANPR & Cổng Chính)'
        ],
        'ipAddress': '192.168.184.206',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '26.5°C',
        'x': 58,
        'y': 38
    },
    {
        'id': 'RACK_07',
        'code': 'RACK-07-GH2',
        'name': 'Tủ RACK Nhà Bảo Vệ 2 — Cổng Logistics/Kho (10U)',
        'nameEn': 'Guardhouse 2 Logistics Gate Rack 07 (10U)',
        'floor': 'PARKING',
        'floorName': 'Cổng Logistics / Kho',
        'room': 'Nhà Bảo Vệ 2 (Cổng Xe Tải cạnh Kho 104 & Dock 105)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Nhà Bảo Vệ 2 (10U)',
        'icon': '🚛',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 16-Port',
            'L2 Switch 08-Port',
            'L2 Switch PoE 08-Port (Camera Giám Sát Cổng Hàng & Dock Xuất Nhập)'
        ],
        'ipAddress': '192.168.184.207',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '26.8°C',
        'x': 39,
        'y': 68
    },
    {
        'id': 'RACK_08',
        'code': 'RACK-08-GH3',
        'name': 'Tủ RACK Nhà Bảo Vệ 3 — Cổng Xe Máy (10U)',
        'nameEn': 'Guardhouse 3 Motorbike Gate Rack 08 (10U)',
        'floor': 'PARKING',
        'floorName': 'Cổng Xe Máy',
        'room': 'Nhà Bảo Vệ 3 (Lối vào Nhà Xe E-Parking)',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Nhà Bảo Vệ 3 (10U)',
        'icon': '🏍️',
        'dimensions': '625x550x600mm (10U)',
        'equipment': [
            'NW-CCTV ODF 08-Port',
            'L2 Switch 08-Port',
            'L2 Switch PoE 08-Port (Camera Kiểm Soát Làn Xe Máy)'
        ],
        'ipAddress': '192.168.184.208',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '27.2°C',
        'x': 22,
        'y': 68
    },
    {
        'id': 'RACK_09',
        'code': 'RACK-09-UTIL',
        'name': 'Tủ RACK Trạm Tiện Ích & XLNT (10U)',
        'nameEn': 'Utility & Wastewater Station Rack 09 (10U)',
        'floor': 'PARKING',
        'floorName': 'Khu Tiện Ích Phụ Trợ',
        'room': 'Trạm Xử Lý Nước Thải & Trạm Bơm PCCC',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Tiện Ích / Ngoài Trời (10U)',
        'icon': '♻️',
        'dimensions': '625x550x600mm (10U IP66)',
        'equipment': [
            'CCTV ODF 04-Port',
            'L2 Switch PoE 08-Port (Camera Giám Sát Trạm Xử Lý Nước Thải & Trạm Bơm)'
        ],
        'ipAddress': '192.168.184.209',
        'power': '220V UPS Backup',
        'status': 'online',
        'temp': '28.0°C',
        'x': 51,
        'y': 51
    }
]

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print('Updated data.json successfully with all 10 RACKs and drawingInfo!')
