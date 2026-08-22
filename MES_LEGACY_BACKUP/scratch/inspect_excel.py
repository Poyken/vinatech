import os
import glob
import zipfile
import xml.etree.ElementTree as ET

def inspect_xlsx(file_path):
    print(f"\n=======================================================")
    print(f"Inspecting: {file_path}")
    with zipfile.ZipFile(file_path, 'r') as z:
        namelist = z.namelist()
        print(f"Archive files: {[n for n in namelist if n.startswith('xl/worksheets/')]}")
        
        # read shared strings if any
        shared_strings = []
        if 'xl/sharedStrings.xml' in namelist:
            ss_xml = z.read('xl/sharedStrings.xml')
            ss_root = ET.fromstring(ss_xml)
            for si in ss_root.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si'):
                texts = [t.text for t in si.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t') if t.text]
                shared_strings.append(''.join(texts))
        
        sheet_files = [n for n in namelist if n.startswith('xl/worksheets/sheet')]
        for sfile in sheet_files:
            print(f"\n--- Sheet file: {sfile} ---")
            sheet_xml = z.read(sfile)
            sheet_root = ET.fromstring(sheet_xml)
            
            rows = []
            for row in sheet_root.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'):
                row_num = row.attrib.get('r')
                cells = {}
                for c in row.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
                    ref = c.attrib.get('r')
                    t = c.attrib.get('t')
                    v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                    val = v.text if v is not None else None
                    if t == 's' and val is not None:
                        idx = int(val)
                        val = shared_strings[idx] if idx < len(shared_strings) else val
                    cells[ref] = val
                rows.append((row_num, cells))
                if len(rows) >= 6:
                    break
            
            for r_num, cells in rows:
                print(f"Row {r_num}: {cells}")

base_dir = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP\scratch\repos\data-sorting"
files = glob.glob(os.path.join(base_dir, "**", "*.xlsx"), recursive=True)
print(f"Total xlsx files in repo: {len(files)}")

if files:
    inspect_xlsx(files[0])
