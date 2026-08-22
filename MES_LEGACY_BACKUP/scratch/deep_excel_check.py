import os
import glob
import zipfile
import xml.etree.ElementTree as ET
from collections import Counter
import sys

# force UTF-8 stdout
sys.stdout.reconfigure(encoding='utf-8')

base_dir = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP\scratch\repos\data-sorting"
files = glob.glob(os.path.join(base_dir, "**", "*.xlsx"), recursive=True)

step_configs = Counter()
header_structures = Counter()

for f in files:
    try:
        with zipfile.ZipFile(f, 'r') as z:
            namelist = z.namelist()
            shared_strings = []
            if 'xl/sharedStrings.xml' in namelist:
                ss_xml = z.read('xl/sharedStrings.xml')
                ss_root = ET.fromstring(ss_xml)
                for si in ss_root.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si'):
                    texts = [t.text for t in si.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t') if t.text]
                    shared_strings.append(''.join(texts))
            
            wb_xml = z.read('xl/workbook.xml')
            wb_root = ET.fromstring(wb_xml)
            sheet_map = {}
            for s in wb_root.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}sheet'):
                sheet_map[s.attrib.get('name')] = s.attrib.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id')
            
            rels_xml = z.read('xl/_rels/workbook.xml.rels')
            rels_root = ET.fromstring(rels_xml)
            rel_to_target = {}
            for r in rels_root.iter('{http://schemas.openxmlformats.org/package/2006/relationships}Relationship'):
                rel_to_target[r.attrib.get('Id')] = 'xl/' + r.attrib.get('Target')
                
            step_file = None
            data_file = None
            for sname, rid in sheet_map.items():
                if "step" in sname.lower():
                    step_file = rel_to_target.get(rid)
                if "aggregatedata" in sname.lower() or "综合" in sname.lower():
                    data_file = rel_to_target.get(rid)
            
            steps = []
            if step_file and step_file in namelist:
                sxml = z.read(step_file)
                sroot = ET.fromstring(sxml)
                for row in sroot.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'):
                    r_num = int(row.attrib.get('r', 0))
                    if r_num >= 2:
                        for c in row.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
                            ref = c.attrib.get('r')
                            if ref.startswith('B'):
                                t = c.attrib.get('t')
                                v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                                val = v.text if v is not None else None
                                if t == 's' and val is not None:
                                    val = shared_strings[int(val)]
                                if val:
                                    steps.append(val)
            step_configs[tuple(steps)] += 1
            
            if data_file and data_file in namelist:
                dxml = z.read(data_file)
                droot = ET.fromstring(dxml)
                h1 = []
                h2 = []
                for row in droot.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}row'):
                    r_num = int(row.attrib.get('r', 0))
                    if r_num == 1:
                        for c in row.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
                            t = c.attrib.get('t')
                            v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                            val = v.text if v is not None else ""
                            if t == 's' and val:
                                val = shared_strings[int(val)]
                            if val:
                                h1.append(val)
                    elif r_num == 2:
                        for c in row.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}c'):
                            t = c.attrib.get('t')
                            v = c.find('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}v')
                            val = v.text if v is not None else ""
                            if t == 's' and val:
                                val = shared_strings[int(val)]
                            if val:
                                h2.append(val)
                        break
                header_structures[(tuple(h1), len(h2))] += 1

    except Exception as ex:
        print(f"Error {f}: {ex}")

print("\n=== STEP CONFIGURATIONS IN EXCEL FILES ===")
for sc, count in step_configs.items():
    print(f"Count: {count} files -> Steps: {sc}")

print("\n=== HEADER STRUCTURES IN DATA SHEET ===")
for hs, count in header_structures.items():
    print(f"Count: {count} files -> Group Headers: {hs[0]}, Col Count: {hs[1]}")
