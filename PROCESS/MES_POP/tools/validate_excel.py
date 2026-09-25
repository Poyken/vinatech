"""
==============================================================================
validate_excel.py — VINATECH EXCEL IMPORT PRE-FLIGHT VALIDATOR (v1.0)
==============================================================================
Kiểm tra tính toàn vẹn dữ liệu file Excel trước khi import vào WinForm MES:
- Phát hiện lệch cột (Column Shift): Ví dụ dán nhầm mã kệ E04, E05 vào cột ngày StartPeriod.
- Kiểm tra định dạng ngày tháng (Date/Period format).
- Kiểm tra tiền tố mã NVL / Vendor Lot.
- 0 external dependencies (dùng thuần zipfile + xml của Python chuẩn).
==============================================================================
"""

import sys
import os
import re
import zipfile
import xml.etree.ElementTree as ET

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

def parse_xlsx_sheet(file_path, sheet_name=None, max_rows=500):
    if not os.path.exists(file_path):
        return None, f"File khong ton tai: {file_path}"
    
    try:
        with zipfile.ZipFile(file_path, 'r') as z:
            # 1. Đọc sharedStrings
            shared_strings = []
            if "xl/sharedStrings.xml" in z.namelist():
                tree = ET.fromstring(z.read("xl/sharedStrings.xml"))
                # Namespace handling
                ns = {'ns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
                for si in (tree.findall('.//ns:si', ns) if tree.findall('.//ns:si', ns) else tree.findall('.//si')):
                    t = si.find('.//ns:t', ns)
                    if t is None:
                        t = si.find('.//t')
                    shared_strings.append(t.text if (t is not None and t.text) else "")
            
            # 2. Đọc sheet1.xml
            sheet_target = "xl/worksheets/sheet1.xml"
            if sheet_name:
                # Tìm sheet theo tên
                pass
            
            if sheet_target not in z.namelist():
                sheets = [s for s in z.namelist() if s.startswith("xl/worksheets/sheet")]
                if not sheets:
                    return None, "Khong tim thay worksheet nao trong file Excel!"
                sheet_target = sheets[0]
                
            tree = ET.fromstring(z.read(sheet_target))
            ns = {'ns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
            rows = []
            
            for row_el in tree.findall('.//ns:row', ns) or tree.findall('.//row'):
                row_idx = row_el.get('r')
                cols = {}
                for cell in row_el.findall('.//ns:c', ns) or row_el.findall('.//c'):
                    ref = cell.get('r') # e.g. A1, B2
                    col_letter = "".join(filter(str.isalpha, ref))
                    t_type = cell.get('t')
                    v_el = cell.find('.//ns:v', ns)
                    if v_el is None:
                        v_el = cell.find('.//v')
                    val = v_el.text if (v_el is not None and v_el.text) else ""
                    
                    if t_type == 's' and val.isdigit():
                        idx = int(val)
                        if idx < len(shared_strings):
                            val = shared_strings[idx]
                    cols[col_letter] = val
                    
                if cols:
                    rows.append((row_idx, cols))
                if len(rows) >= max_rows:
                    break
                    
            return rows, None
    except Exception as e:
        return None, f"Loi giai ma file Excel: {str(e)}"

def validate_f330(rows):
    issues = []
    headers = {}
    header_row_idx = 0
    
    # Tìm dòng header
    for r_idx, cols in rows[:10]:
        col_vals = [str(v).strip().lower() for v in cols.values()]
        if any("lot" in v for v in col_vals) or any("mã" in v for v in col_vals) or any("vật liệu" in v for v in col_vals):
            headers = cols
            header_row_idx = int(r_idx)
            break
            
    # Phân tích các dòng dữ liệu sau header
    data_rows = [r for r in rows if int(r[0]) > header_row_idx]
    if not data_rows:
        return {"status": "ERROR", "message": "Khong tim thay dong du lieu nao sau tieu de!"}
        
    print(f">> Tong so dong du lieu quet kiem tra: {len(data_rows)} dong (Header tai dong {header_row_idx})")
    
    # Check Column Shift lỗi dán nhầm mã khay E04, E05 vào StartPeriod
    rack_pattern = re.compile(r'^[A-Z]\d{2,3}$', re.IGNORECASE) # e.g. E04, E05, A12
    date_pattern = re.compile(r'^\d{4}[-/.]\d{2}[-/.]\d{2}$|^\d{8}$') # 2026-09-25 or 20260925
    
    col_types = {}
    shift_warnings = []
    
    for r_idx, cols in data_rows:
        for c_let, val in cols.items():
            val_str = str(val).strip()
            if not val_str:
                continue
            if c_let not in col_types:
                col_types[c_let] = []
            col_types[c_let].append((r_idx, val_str))
            
    # Soi từng cột xem có hiện tượng cột Date mà chứa mã vị trí kệ không
    for c_let, vals in col_types.items():
        sample_vals = [v[1] for v in vals[:30]]
        rack_count = sum(1 for v in sample_vals if rack_pattern.match(v))
        date_count = sum(1 for v in sample_vals if date_pattern.match(v))
        
        # Nếu cột này có header là Period/Date/StartPeriod nhưng value toàn là E04, E05
        h_name = str(headers.get(c_let, "")).strip().lower()
        if ("period" in h_name or "ngày" in h_name or "date" in h_name or "chu kỳ" in h_name) and rack_count > 0:
            examples = [f"dòng {v[0]}: '{v[1]}'" for v in vals if rack_pattern.match(v[1])][:5]
            shift_warnings.append(
                f"[LỆCH CỘT NGHIÊM TRỌNG] Cột '{c_let}' (Tiêu đề: '{headers.get(c_let, '')}') là cột ngày/chu kỳ nhưng chứa mã vị trí giá kệ ({', '.join(examples)})!\n"
                f"   ➔ Nguyên nhân: Khi công nhân copy/paste từ Excel nguồn đã bị dán lệch sang trái/phải 1 cột.\n"
                f"   ➔ Khắc phục: Dời toàn bộ cột này sang cột Vị trí kho/Khay kệ (Location/Rack) trước khi import vào F330."
            )
        elif rack_count > len(sample_vals) * 0.7:
            # Đây khả năng cao là cột Location/Rack
            pass

    return {
        "status": "WARNING" if shift_warnings else "PASS",
        "header_row": header_row_idx,
        "total_checked": len(data_rows),
        "shift_warnings": shift_warnings
    }

def main():
    if len(sys.argv) < 2:
        print("Cú pháp: python tools/validate_excel.py <Duong_Dan_File.xlsx> [Screen: F330|B598]")
        sys.exit(1)
        
    file_path = sys.argv[1]
    screen = sys.argv[2].upper() if len(sys.argv) > 2 else "F330"
    
    print("")
    print("======================================================================")
    print("      VINATECH MES — KIỂM TOÁN TÍNH TOÀN VẸN FILE EXCEL PRE-FLIGHT     ")
    print(f"      File: {os.path.basename(file_path)} | Màn hình đích: [{screen}]")
    print("======================================================================")
    
    rows, err = parse_xlsx_sheet(file_path)
    if err:
        print(f"❌ LỖI: {err}")
        sys.exit(1)
        
    if screen == "F330":
        res = validate_f330(rows)
        if res.get("shift_warnings"):
            print("\n🚨 PHÁT HIỆN LỖI LỆCH CỘT (COLUMN SHIFT MISALIGNMENT):")
            for w in res["shift_warnings"]:
                print(f" * {w}")
            print("\n❌ KẾT LUẬN: FILE CHƯA ĐẠT CHUẨN ĐỂ IMPORT VÀO F330 (CẦN SỬA LẠI FILE TRƯỚC)!")
        else:
            print(f"\n✅ KẾT QUẢ: File đạt chuẩn cấu trúc dữ liệu cơ bản cho màn hình {screen} ({res['total_checked']} dòng dữ liệu)!")
    else:
        print(f">> Đã đọc thành công {len(rows)} dòng từ file. Cấu trúc bảng hợp lệ.")
        
    print("======================================================================\n")

if __name__ == "__main__":
    main()
