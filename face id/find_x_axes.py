import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def find_x_axes(pno):
    page = doc[pno - 1]
    print(f"\nSearching X Axes on Page {pno}...")
    blocks = page.get_text('blocks')
    for b in blocks:
        text = b[4].strip()
        # look for single numbers or numbers with X
        lines = text.split('\n')
        if len(lines) <= 2 and any(lines[0] == str(i) for i in range(1, 20)):
            print(f"  Block [{b[0]:6.1f}, {b[1]:6.1f}, {b[2]:6.1f}, {b[3]:6.1f}]: '{text.replace(chr(10), ' ')}'")

find_x_axes(13)
