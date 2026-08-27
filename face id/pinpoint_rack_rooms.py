import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def pinpoint_room(pno, target_x, target_y, label):
    page = doc[pno-1]
    print(f"\n==================== Pinpoint {label} on Page {pno} at ({target_x}, {target_y}) ====================")
    blocks = page.get_text('blocks')
    surrounding = []
    for b in blocks:
        bx = (b[0] + b[2]) / 2
        by = (b[1] + b[3]) / 2
        dist = ((bx - target_x)**2 + (by - target_y)**2)**0.5
        if dist < 180: # within 180 points
            text = " ".join(b[4].split())
            surrounding.append((dist, text, (bx, by)))
            
    surrounding.sort(key=lambda x: x[0])
    for d, text, (bx, by) in surrounding:
        print(f"  dist {d:5.1f} pt -> [{bx:6.1f}, {by:6.1f}] : {text}")

# 1F Racks
pinpoint_room(13, 477.1, 225.1, "RACK 1 (1F)")
pinpoint_room(13, 254.0, 480.1, "RACK 2 (1F)")
pinpoint_room(13, 910.8, 582.6, "RACK 3 (1F)")

# 2F Racks
pinpoint_room(15, 417.6, 204.3, "RACK 4 (2F)")
pinpoint_room(15, 153.6, 611.1, "RACK MAIN (2F)")
