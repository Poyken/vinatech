import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

page = doc[18] # Page 19 (Master Plan)
blocks = page.get_text('blocks')

print(f"=== PAGE 19 (CCTV Master Plan) Page Width={page.rect.width}, Height={page.rect.height} ===")
for b in sorted(blocks, key=lambda x: (x[1], x[0])):
    text = " ".join(b[4].split())
    if not any(k in text for k in ['VINHOMES', 'DOUL ASIA', 'CLIENT', 'HWANG', 'XUÂN HIẾU', 'GIAI ĐOẠN', 'HỒ SƠ']):
        if len(text) > 1:
            print(f"[{b[0]:6.1f}, {b[1]:6.1f}, {b[2]:6.1f}, {b[3]:6.1f}] : {text}")
