import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def detailed_floor_map(pno, name):
    page = doc[pno-1]
    print(f"\n{'='*30} {name} (Page {pno}) {'='*30}")
    blocks = page.get_text('blocks')
    for b in sorted(blocks, key=lambda x: (x[1], x[0])):
        text = " ".join(b[4].split())
        if any(k in text.upper() for k in ['RACK', '101', '104', '105', '108', '109', '112', '113', '118', '120', '128', '129', '131', '136', '137', '151', '201', '202', '203', '204', '206', '233', '302', '303', '304', '305', '306', '311', '312', '313', '314', '315', '316', '317', '333', '401', '402', 'GUARD', 'TRẠM', 'BIẾN ÁP', 'PCCC', 'BƠM', 'NƯỚC THẢI']):
            if len(text) < 100:
                print(f"  [{b[0]:6.1f}, {b[1]:6.1f}, {b[2]:6.1f}, {b[3]:6.1f}] : {text}")

detailed_floor_map(13, "1F Network & PBX")
detailed_floor_map(15, "2F Network & PBX")
detailed_floor_map(18, "Guardhouse Network")
detailed_floor_map(19, "CCTV Master Plan")
detailed_floor_map(28, "Flap Barrier E-Parking")
