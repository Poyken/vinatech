import json

# 1. Update data.json with exact CAD-derived coordinates and information
with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Update itRacks
data['itRacks'] = [
    {
        'id': 'RACK_MAIN',
        'code': 'RACK-MAIN-42U',
        'name': 'Tủ RACK IT & Server Trung Tâm 42U',
        'nameEn': 'Main IT Server Rack 42U (D1000)',
        'floor': '2F',
        'floorName': 'Tầng 2 Khối Văn Phòng',
        'room': 'Phòng IT & Server Room (304) [Trục 1X–2X / 2Y–3Y]',
        'type': 'IT_RACK',
        'typeLabel': 'Tủ Server Trung Tâm 42U',
        'icon': '🖥️',
        'dimensions': '600x1000x2100mm (42U)',
        'equipment': [
            'Firewall Fortinet FortiGate 100E (HA Ready)',
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
        'x': 18,
        'y': 62
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
        'x': 20,
        'y': 62
    },
    {
        'id': 'RACK_01',
        'code': 'RACK-01-1F',
        'name': 'Tủ Phân Phối Tầng 1 — Khu Sản Xuất 1 (10U)',
        'nameEn': '1F Production Rack 01 (10U)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Hành Lang gần VP Xưởng 3 (109) & P. Lắp Ráp 1 [Trục 9X–10X / 9Y–10Y]',
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
        'x': 52,
        'y': 15
    },
    {
        'id': 'RACK_02',
        'code': 'RACK-02-1F',
        'name': 'Tủ Phân Phối Tầng 1 — Khu Điều Khiển & Định Hình (10U)',
        'nameEn': '1F Control & Formation Rack 02 (10U)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Khu P. Điều Khiển Mixer 1 (128) & P. Định Hình 1 (131) [Trục 5X–6X / 4Y–5Y]',
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
        'x': 27,
        'y': 48
    },
    {
        'id': 'RACK_03',
        'code': 'RACK-03-1F',
        'name': 'Tủ Phân Phối Tầng 1 — Khu QC, PCCC & Đóng Gói (10U)',
        'nameEn': '1F QC, Fire & Packing Rack 03 (10U)',
        'floor': '1F',
        'floorName': 'Tầng 1 Nhà Xưởng',
        'room': 'Hành Lang cạnh VP Xưởng 1 (118), QC 136 & PCCC 151 [Trục 16X–17X / 2Y–3Y]',
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
        'x': 92,
        'y': 58
    },
    {
        'id': 'RACK_04',
        'code': 'RACK-04-2F',
        'name': 'Tủ Phân Phối Tầng 2 — Xưởng Sản Xuất 2F (10U)',
        'nameEn': '2F Production Floor Rack 04 (10U)',
        'floor': '2F',
        'floorName': 'Tầng 2 Nhà Xưởng',
        'room': 'Khu VP Xưởng 2 (313), VP Xưởng 1 (316) & Module Working (311) [Trục 8X–9X / 8Y–9Y]',
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
        'x': 43,
        'y': 21
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
        'x': 57,
        'y': 39
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
        'y': 52
    }
]

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print('Updated data.json successfully with precise CAD positions!')
