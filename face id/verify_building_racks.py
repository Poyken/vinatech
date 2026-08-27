import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def check_internal_racks():
    # Let's inspect Page 13 (1F Net) and Page 15 (2F Net)
    for pno, name in [(13, "1F NET/PBX"), (15, "2F NET/PBX"), (20, "1F CCTV"), (22, "2F CCTV"), (25, "1F TA/AC"), (27, "2F TA/AC")]:
        page = doc[pno-1]
        print(f"\n==================== {name} (Page {pno}) ====================")
        blocks = page.get_text('blocks')
        for b in blocks:
            text = " ".join(b[4].split())
            if any(k in text for k in ['RACK_01', 'RACK_02', 'RACK_03', 'RACK_04', 'RACK_MAIN', 'RACK 1', 'RACK 2', 'RACK 3', 'RACK 4', 'Rack_1', 'Rack_2', 'Rack_3', 'Rack_4', 'Rack Main', 'Rack_IT', 'RACK-10U', 'RACK-42U']):
                print(f"  Pos [{b[0]:.1f}, {b[1]:.1f}, {b[2]:.1f}, {b[3]:.1f}] -> '{text}'")

check_internal_racks()
