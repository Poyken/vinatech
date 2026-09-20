import pymupdf

# Build Code 128 lookup tables
# Table for Start B / Code B characters
CODE128_PATTERNS = [
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
    (2,1,1,2,3,2), # 104: Start A, 105: Start B
]

# Code B characters (index 0 to 95: ASCII 32 to 127)
CODE_B = [chr(i) for i in range(32, 128)]

def decode_image_barcode(img_path, rect, label):
    pix = pymupdf.Pixmap(img_path)
    w, h = pix.width, pix.height
    samples = pix.samples
    x1, y1, x2, y2 = rect
    
    print(f"=== {label} ===")
    for y in range(y1, y2, 2):
        # Sample horizontally, ignore pure red
        gray_vals = []
        for x in range(x1, x2):
            idx = (y * w + x) * 3
            r, g, b = samples[idx], samples[idx+1], samples[idx+2]
            # If red border, skip
            if r > 160 and g < 70 and b < 70:
                gray = 255 # treat as background
            else:
                gray = int(0.299*r + 0.587*g + 0.114*b)
            gray_vals.append(gray)
            
        # Threshold
        thresh = 110
        bits = [1 if g < thresh else 0 for g in gray_vals]
        
        # Find runs
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
        
        # Strip leading/trailing 0s
        first_1 = next((i for i, (c, l) in enumerate(runs) if c == 1), -1)
        last_1 = next((i for i in range(len(runs)-1, -1, -1) if runs[i][0] == 1), -1)
        if first_1 == -1 or last_1 == -1:
            continue
        core = runs[first_1:last_1+1]
        
        # Filter tiny noise runs
        if len(core) < 30:
            continue
            
        # Let's print the number of elements and total modules
        # A valid Code 128 stop pattern is 2,3,3,1,1,1,2 (bar,space,bar,space,bar,space,bar)
        # Let's see if we find Start B: (2,1,1,2,3,2) -> (bar2, space1, bar1, space2, bar3, space2)
        # Ratio of first 6 elements:
        w_first6 = sum(l for c, l in core[:6])
        elem_ratios = [round(l * 11 / w_first6) for c, l in core[:6]]
        if tuple(elem_ratios) == (2, 1, 1, 2, 3, 2):
            print(f"y={y}: FOUND START B PATTERN! Total elements: {len(core)}")
            # Let's decode all characters!
            idx = 0
            decoded_chars = []
            while idx + 6 <= len(core):
                chunk = core[idx:idx+6]
                w_chunk = sum(l for c, l in chunk)
                norm = tuple(round(l * 11 / w_chunk) for c, l in chunk)
                # find closest match in CODE128_PATTERNS
                best_match = None
                best_diff = 999
                for p_idx, pat in enumerate(CODE128_PATTERNS):
                    diff = sum(abs(a - b) for a, b in zip(norm, pat))
                    if diff < best_diff:
                        best_diff = diff
                        best_match = p_idx
                if best_diff <= 2:
                    if best_match == 104 or best_match == 105:
                        decoded_chars.append(f"[START_{best_match}]")
                    elif best_match < len(CODE_B):
                        decoded_chars.append(CODE_B[best_match])
                    else:
                        decoded_chars.append(f"[{best_match}]")
                else:
                    decoded_chars.append(f"?({norm})")
                idx += 6
            print(f"Decoded string at y={y}: {''.join(decoded_chars)}")
            break

decode_image_barcode(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762507285.jpg", (450, 250, 710, 390), "OK")
decode_image_barcode(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762512623.jpg", (380, 100, 670, 230), "NG")
