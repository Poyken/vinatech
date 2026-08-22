import os
import glob
import zipfile
import xml.etree.ElementTree as ET
from collections import defaultdict

base_dir = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP\scratch\repos\data-sorting"
files = glob.glob(os.path.join(base_dir, "**", "*.xlsx"), recursive=True)

print(f"Total xlsx files in repo: {len(files)}")

day_stats = defaultdict(lambda: {"files": 0, "rows": 0, "non_empty_barcode": 0, "non_empty_tray": 0, "machines": set()})
corrupted_files = []

for idx, f in enumerate(files):
    # Determine date folder
    parts = f.replace('/', '\\').split('\\')
    # find yyyy-mm-dd in parts
    date_part = "unknown"
    for p in parts:
        if len(p) == 10 and p[4] == '-' and p[7] == '-':
            date_part = p
            break
            
    fname = os.path.basename(f)
    eq = "1#" if fname.startswith("1#") else ("2#" if fname.startswith("2#") else "Unknown")
    
    try:
        with zipfile.ZipFile(f, 'r') as z:
            namelist = z.namelist()
            # find the data sheet
            # read workbook.xml
            wb_xml = z.read('xl/workbook.xml')
            wb_root = ET.fromstring(wb_xml)
            sheet_map = {}
            for s in wb_root.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}sheet'):
                sheet_map[s.attrib.get('name')] = s.attrib.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id')
            
            # find AggregateData sheet
            target_sheet_rel = None
            for sname, rel in sheet_map.items():
                if "aggregatedata" in sname.lower() or "综合" in sname.lower():
                    target_sheet_rel = rel
                    break
            
            # map rel to file
            rels_xml = z.read('xl/_rels/workbook.xml.rels')
            rels_root = ET.fromstring(rels_xml)
            sheet_target_file = None
            for r in rels_root.iter('{http://schemas.openxmlformats.org/package/2006/relationships}Relationship'):
                if r.attrib.get('Id') == target_sheet_rel:
                    sheet_target_file = 'xl/' + r.attrib.get('Target')
                    break
            
            if not sheet_target_file or sheet_target_file not in namelist:
                # fallback to sheet3 or sheet2
                for sname in ['xl/worksheets/sheet3.xml', 'xl/worksheets/sheet2.xml', 'xl/worksheets/sheet1.xml']:
                    if sname in namelist:
                        sheet_target_file = sname
                        break
                        
            sheet_xml = z.read(sheet_target_file)
            sheet_root = ET.fromstring(sheet_xml)
            
            # count rows (row r >= 3)
            row_count = 0
            has_barcode = 0
            has_tray = 0
            for row in sheet_root.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'):
                r_num = int(row.attrib.get('r', 0))
                if r_num >= 3:
                    row_count += 1
            
            day_stats[date_part]["files"] += 1
            day_stats[date_part]["rows"] += row_count
            day_stats[date_part]["machines"].add(eq)
            
    except Exception as e:
        corrupted_files.append((f, str(e)))

print("\n=== REPOSITORY DATA BY DAY ===")
print(f"{'Date':<12} | {'Files':<6} | {'Total Rows':<12} | {'Avg Rows/File':<14} | {'Machines'}")
print("-" * 65)
total_repo_files = 0
total_repo_rows = 0
for d in sorted(day_stats.keys()):
    st = day_stats[d]
    total_repo_files += st['files']
    total_repo_rows += st['rows']
    avg = st['rows'] / st['files'] if st['files'] > 0 else 0
    print(f"{d:<12} | {st['files']:<6} | {st['rows']:<12} | {avg:<14.1f} | {list(st['machines'])}")

print("-" * 65)
print(f"TOTAL REPO: {total_repo_files} files, {total_repo_rows} rows")
if corrupted_files:
    print(f"Corrupted files: {len(corrupted_files)}")
    for cf in corrupted_files[:5]:
        print(f"  {cf}")
