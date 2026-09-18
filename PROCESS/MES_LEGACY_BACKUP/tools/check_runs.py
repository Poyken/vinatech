import pymupdf

def print_runs(img_path, rect, label):
    pix = pymupdf.Pixmap(img_path)
    w, h = pix.width, pix.height
    samples = pix.samples
    x1, y1, x2, y2 = rect
    
    mid_y = (y1 + y2) // 2
    gray_vals = []
    for x in range(x1, x2):
        idx = (mid_y * w + x) * 3
        r, g, b = samples[idx], samples[idx+1], samples[idx+2]
        if r > 160 and g < 70 and b < 70:
            gray = 255
        else:
            gray = int(0.299*r + 0.587*g + 0.114*b)
        gray_vals.append(gray)
        
    thresh = 110
    bits = [1 if g < thresh else 0 for g in gray_vals]
    runs = []
    c = bits[0]
    l = 1
    for b in bits[1:]:
        if b == c:
            l += 1
        else:
            runs.append((c, l))
            c = b
            l = 1
    runs.append((c, l))
    
    first_1 = next((i for i, (c, l) in enumerate(runs) if c == 1), -1)
    last_1 = next((i for i in range(len(runs)-1, -1, -1) if runs[i][0] == 1), -1)
    core = runs[first_1:last_1+1]
    
    print(f"=== {label} (total {len(core)} runs, width {sum(l for c, l in core)}px) ===")
    print("From Left to Right (first 12 elements):")
    print(core[:12])
    print("From Right to Left (last 12 elements):")
    print(core[-12:])

print_runs(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762507285.jpg", (450, 310, 710, 340), "OK")
print_runs(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762512623.jpg", (380, 150, 670, 180), "NG")
