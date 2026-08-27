import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

for pno in [19, 38, 39, 40, 41, 42, 43]:
    page = doc[pno - 1]
    print(f"\n{'='*35} Page {pno} {'='*35}")
    blocks = page.get_text('blocks')
    for b in sorted(blocks, key=lambda x: (x[1], x[0])):
        text = " ".join(b[4].split())
        if any(k in text.upper() for k in [
            'GATE', 'GUARD', 'RACK', 'ISP', 'HDPE', 'FENCE', 'HÀNG RÀO', 'CỔNG', 
            'BẢO VỆ', 'NHÀ XE', 'PARKING', 'SUBSTATION', 'BIẾN ÁP', 'PCCC', 'BƠM', 
            'NƯỚC THẢI', 'TRẠM', 'MAN HOLE', 'HỐ GA', 'TỦ', 'POLE', 'CỘT', 'ROAD', 'ĐƯỜNG'
        ]):
            if len(text) < 120:
                print(f"  [{b[0]:6.1f}, {b[1]:6.1f}, {b[2]:6.1f}, {b[3]:6.1f}] : {text}")
