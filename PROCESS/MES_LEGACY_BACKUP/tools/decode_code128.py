# Pure Python Code 128 Decoder
import pymupdf

# Standard Code 128 patterns (b1, s1, b2, s2, b3, s3)
PATTERNS = [
    (2,1,2,2,2,2), (2,2,2,1,2,2), (2,2,2,2,2,1), (1,2,1,2,2,3), (1,2,1,3,2,2), # 0-4
    (1,3,1,2,2,2), (1,2,2,2,1,3), (1,2,2,3,1,2), (1,3,2,2,1,2), (2,2,1,2,1,3), # 5-9
    (2,2,1,3,1,2), (2,3,1,2,1,2), (1,1,2,2,3,2), (1,2,2,1,3,2), (1,2,2,2,3,1), # 10-14
    (1,1,3,2,2,2), (1,2,3,1,2,2), (1,2,3,2,2,1), (2,2,3,2,1,1), (2,2,1,1,3,2), # 15-19
    (2,2,1,2,3,1), (2,1,3,2,1,2), (2,2,3,1,1,2), (3,1,2,1,3,1), (3,1,1,2,2,2), # 20-24
    (3,2,1,1,2,2), (3,2,1,2,2,1), (3,1,2,2,1,2), (3,2,2,1,1,2), (3,2,2,2,1,1), # 25-29
    (2,1,2,1,2,3), (2,1,2,3,2,1), (2,3,2,1,2,1), (1,1,1,3,2,3), (1,3,1,1,2,3), # 30-34
    (1,3,1,3,2,1), (1,1,2,3,1,3), (1,3,2,1,1,3), (1,3,2,3,1,1), (2,1,1,3,1,3), # 35-39
    (2,3,1,1,1,3), (2,3,1,3,1,1), (1,1,2,1,3,3), (1,1,2,3,3,1), (1,3,2,1,3,1), # 40-44
    (1,1,3,1,2,3), (1,1,3,3,2,1), (1,3,3,1,2,1), (3,1,3,1,2,1), (2,1,1,3,3,1), # 45-49
    (2,3,1,1,3,1), (2,1,3,1,1,3), (2,1,3,3,1,1), (2,1,3,1,3,1), (3,1,1,1,2,3), # 50-54
    (3,1,1,3,2,1), (3,3,1,1,2,1), (3,1,2,1,1,3), (3,1,2,3,1,1), (3,3,2,1,1,1), # 55-59
    (3,1,4,1,1,1), (2,2,1,4,1,1), (4,3,1,1,1,1), (1,1,1,2,2,4), (1,1,1,4,2,2), # 60-64
    (1,2,1,1,2,4), (1,2,1,4,2,1), (1,4,1,1,2,2), (1,4,1,2,2,1), (1,1,2,2,1,4), # 65-69
    (1,1,2,4,1,2), (1,2,2,1,1,4), (1,2,2,4,1,1), (1,4,2,1,1,2), (1,4,2,2,1,1), # 70-74
    (2,4,1,2,1,1), (2,2,1,1,1,4), (4,1,3,1,1,1), (2,4,1,1,1,2), (1,3,4,1,1,1), # 75-79
    (1,1,1,2,4,2), (1,2,1,1,4,2), (1,2,1,2,4,1), (1,1,4,2,1,2), (1,2,4,1,1,2), # 80-84
    (1,2,4,2,1,1), (4,1,1,2,1,2), (4,2,1,1,1,2), (4,2,1,2,1,1), (2,1,2,1,4,1), # 85-89
    (2,1,4,1,2,1), (4,1,2,1,2,1), (1,1,1,1,4,3), (1,1,1,3,4,1), (1,3,1,1,4,1), # 90-94
    (1,1,4,1,1,3), (1,1,4,3,1,1), (4,1,1,1,1,3), (4,1,1,3,1,1), (1,1,3,1,4,1), # 95-99
    (1,1,4,1,3,1), (3,1,1,1,4,1), (4,1,1,1,3,1), (2,1,1,4,1,2), (2,1,1,2,1,4), # 100-104
    (2,1,1,2,3,2), # 105 (START B)
    (2,3,3,1,1,1,2) # 106 STOP
]

# Let's write a robust scanner that samples across multiple scanlines
def decode_code128_from_image(img_path, rect, label):
    pix = pymupdf.Pixmap(img_path)
    w, h = pix.width, pix.height
    samples = pix.samples
    x1, y1, x2, y2 = rect
    
    print(f"\n--- Decoding {label} ---")
    for y_offset in range(10, y2 - y1 - 10, 5):
        y = y1 + y_offset
        # Extract binary profile
        vals = []
        for x in range(x1, x2):
            idx = (y * w + x) * 3
            gray = int(0.299 * samples[idx] + 0.587 * samples[idx+1] + 0.114 * samples[idx+2])
            vals.append(gray)
        
        # Otsu or simple min/max threshold
        min_v, max_v = min(vals), max(vals)
        if max_v - min_v < 60:
            continue
        thresh = (min_v + max_v) // 2
        bin_line = [1 if v < thresh else 0 for v in vals]
        
        # Run-length encode
        runs = []
        curr = bin_line[0]
        length = 1
        for b in bin_line[1:]:
            if b == curr:
                length += 1
            else:
                runs.append((curr, length))
                curr = b
                length = 1
        runs.append((curr, length))
        
        # Filter leading/trailing white space
        first_bar_idx = next((i for i, (c, l) in enumerate(runs) if c == 1), -1)
        last_bar_idx = next((i for i in range(len(runs)-1, -1, -1) if runs[i][0] == 1), -1)
        
        if first_bar_idx == -1 or last_bar_idx == -1:
            continue
            
        core_runs = runs[first_bar_idx:last_bar_idx+1]
        # Total bars and spaces
        # Standard Code 128 has: Start (6), N chars (6*N), Check (6), Stop (7) = 6*(N+2) + 1 elements
        n_elem = len(core_runs)
        print(f"y={y}: found {n_elem} elements, total width = {sum(l for c, l in core_runs)} px")
        if (n_elem - 1) % 6 == 0:
            n_chars = (n_elem - 1) // 6 - 2
            print(f"  -> Matches exact Code 128 element count for {n_chars} characters! (Total data chars={n_chars})")

decode_code128_from_image(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762507285.jpg", (440, 245, 715, 395), "OK")
decode_code128_from_image(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762512623.jpg", (370, 90, 680, 245), "NG")
