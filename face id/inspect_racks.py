import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

pages_to_check = [
    (13, "Page 13: 1F Network & PBX"),
    (15, "Page 15: 2F Network & PBX"),
    (18, "Page 18: Guardhouse Network"),
    (19, "Page 19: CCTV Master Plan"),
    (25, "Page 25: 1F TA/AC"),
    (27, "Page 27: 2F TA/AC"),
    (39, "Page 39: Backbone Network Master Plan"),
    (40, "Page 40: Backbone CCTV Master Plan"),
]

for pno, desc in pages_to_check:
    page = doc[pno - 1]
    print(f"\n{'='*30} {desc} {'='*30}")
    blocks = page.get_text('blocks')
    for b in blocks:
        text = b[4].strip()
        if any(k in text.upper() for k in ['RACK', 'GUARD', 'IT ROOM', 'EPS', 'MIXER', 'KHO', 'CĂN TIN', 'SHOW ROOM', 'VĂN PHÒNG', 'P.', 'DOCK']):
            clean = " | ".join(text.splitlines())
            print(f"  [{b[0]:.1f}, {b[1]:.1f}] : {clean}")
