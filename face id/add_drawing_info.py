import json

with open("data.json", "r", encoding="utf-8") as f:
    data = json.load(f)

data["drawingInfo"] = {
  "project": "VINATECH VINA HƯNG YÊN FACTORY",
  "drawingNo": "ELV-42/01 to 42/43",
  "version": "v5.2 (2026.06.15)",
  "designer": "DOUL ASIA CO., LTD",
  "contractor": "WORLDSTAR INTERNATIONAL J.S.C",
  "summary": {
    "networkPbx": [
      {"no": 1, "item": "Firewall (Fortinet FortiGate 100E HA Ready)", "unit": "EA", "qty": 1, "model": "Fortinet FortiGate 100E"},
      {"no": 2, "item": "L3 Switch 24 Port (Core Switch Trung Tâm)", "unit": "EA", "qty": 1, "model": "24-Port GbE + 4 SFP+ Uplink"},
      {"no": 3, "item": "L2 Switch 48 Port (Switch Phân Phối Tầng Cisco)", "unit": "EA", "qty": 3, "model": "Cisco 48-Port Managed GbE"},
      {"no": 4, "item": "L2 Switch 24 Port", "unit": "EA", "qty": 2, "model": "24-Port Gigabit Managed"},
      {"no": 5, "item": "L2 Switch 08 Port", "unit": "EA", "qty": 5, "model": "8-Port Gigabit Desktop/Rack"},
      {"no": 6, "item": "Access Point (Wi-Fi 6 AP Doanh Nghiệp)", "unit": "EA", "qty": 8, "model": "Dual-Band Gigabit Wi-Fi 6 AX3000"},
      {"no": 7, "item": "Cable Management 1U (Thanh Quản Lý Cáp)", "unit": "EA", "qty": 14, "model": "19 inch 1U Cable Organizer"},
      {"no": 8, "item": "02 LAN, Wall Outlet (Ổ Cắm Mạng Đôi Âm Tường)", "unit": "SET", "qty": 4, "model": "Mặt Nạ 2 Port + Nhân Cat6 RJ45"},
      {"no": 9, "item": "01 LAN, 01 TEL, Wall Outlet (Ổ Mạng + Thoại IP Phone)", "unit": "SET", "qty": 3, "model": "Mặt Nạ RJ45 + RJ11 (3 Nhà Bảo Vệ)"},
      {"no": 10, "item": "06 LAN, Wall Outlet (Cụm Bàn Họp 6 Port)", "unit": "SET", "qty": 1, "model": "Hộp Đa Năng Bàn Họp 6 Port Cat6"},
      {"no": 11, "item": "04 LAN, Wall Outlet (Cụm Bàn Làm Việc 4 Port)", "unit": "SET", "qty": 6, "model": "Hộp 4 Port Gắn Bàn Làm Việc Cat6"},
      {"no": 12, "item": "01 LAN, Wall Outlet (Ổ Cắm Mạng Đơn Âm Tường)", "unit": "SET", "qty": 22, "model": "Mặt Nạ 1 Port RJ45 Cat6"},
      {"no": 13, "item": "01 LAN, Floor Outlet (Ổ Cắm Mạng Âm Sàn Nhà Xưởng)", "unit": "SET", "qty": 58, "model": "Hộp Đồng Âm Sàn Nắp Mở Brass Box"},
      {"no": 14, "item": "Media Converter (Bộ Chuyển Đổi Quang - Điện)", "unit": "EA", "qty": 2, "model": "1000Base-SX to 1000Base-T (18 SET tổng)"},
      {"no": 15, "item": "ODF Hộp Phối Quang (Fiber Patch Panel)", "unit": "EA", "qty": 9, "model": "ODF 52P, 16P, 12P, 8P, 4P SC/LC"},
      {"no": 16, "item": "UPS Bộ Lưu Điện Dự Phòng (Online UPS 10kVA)", "unit": "EA", "qty": 1, "model": "Online UPS 10kVA Pure Sine Wave"},
      {"no": 17, "item": "Rack Cabinet (Hệ Thống Tủ RACK IT)", "unit": "EA", "qty": 9, "model": "42U D1000, 10U D600, Outside IP66"},
      {"no": 18, "item": "Tổng Đài IP PBX Server", "unit": "EA", "qty": 1, "model": "IP PBX Server 100 Extensions"},
      {"no": 19, "item": "Điện Thoại IP Phone (Bàn Văn Phòng & Bảo Vệ)", "unit": "EA", "qty": 23, "model": "HD Voice IP Phone PoE"}
    ],
    "taAc": [
      {"no": 1, "item": "Time Attendance (Máy Chấm Công Khuôn Mặt)", "unit": "EA", "qty": 5, "model": "TA_1, TA_2, TA_3, TA_4, TA_5 (Treo tường 1.2m)"},
      {"no": 2, "item": "Access Control (Đầu Đọc Kiểm Soát Mở Cửa & Barrier)", "unit": "EA", "qty": 16, "model": "AC_1..AC_6 (Cửa) + AC_10..AC_19 (10 Làn Barrier)"},
      {"no": 3, "item": "Flapgate (Cổng Phân Làn Tự Động Nhà Xe)", "unit": "EA", "qty": 6, "model": "02 Thân Biên Left/Right + 04 Thân Giữa Center"},
      {"no": 4, "item": "Doorlock (Khóa Từ & Khóa Chốt Rơi)", "unit": "EA", "qty": 6, "model": "Khóa Hút Từ 280kg (AC_1,3,4,6) + Khóa Chốt (AC_2,5)"},
      {"no": 5, "item": "Exit Button (Nút Nhấn / Cảm Ứng Mở Cửa)", "unit": "EA", "qty": 6, "model": "Nút Cảm Ứng Không Chạm + Đập Kính Khẩn Cấp"},
      {"no": 6, "item": "Faces sample device (Trạm Đăng Ký Khuôn Mặt USB)", "unit": "EA", "qty": 1, "model": "USB 3.0 Desktop Enrollment Reader (P. IT)"},
      {"no": 7, "item": "Inox Fence (Hàng Rào Inox Dẫn Làn)", "unit": "SET", "qty": 2, "model": "Hàng Rào Inox 304 Phân Luồng Nhà Xe"},
      {"no": 8, "item": "PC Server Quản Trị Hệ Thống HikCentral", "unit": "EA", "qty": 1, "model": "Dell Server Management Workstation Client"},
      {"no": 9, "item": "L2 Switch 16 Port (Switch Chuyên Dụng Flap Barrier)", "unit": "EA", "qty": 1, "model": "16-Port Gigabit Managed (RACK_MAIN/RACK_05)"},
      {"no": 10, "item": "L2 Switch 08 Port (Switch Chuyên Dụng Access Control)", "unit": "EA", "qty": 2, "model": "8-Port Gigabit Switch (RACK_MAIN & RACK_03)"},
      {"no": 11, "item": "Cable Management 1U (Thanh Quản Lý Cáp)", "unit": "EA", "qty": 3, "model": "19 inch 1U Cable Organizer"}
    ],
    "grounding": [
      {"no": 1, "item": "Testing Box (Hộp Kiểm Tra Điện Trở Tiếp Địa)", "unit": "EA", "qty": 1, "model": "Hộp đo điện trở tiếp địa chống sét & an toàn ELV"}
    ],
    "isp": [
      {"no": 1, "item": "ISP ODF (Hộp Phối Quang Đầu Vào Nhà Mạng)", "unit": "EA", "qty": 1, "model": "ODF 08-Port SC/APC kết nối tuyến cáp quang ngầm KCN"}
    ]
  }
}

with open("data.json", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Added 100% verified drawingInfo into data.json")
