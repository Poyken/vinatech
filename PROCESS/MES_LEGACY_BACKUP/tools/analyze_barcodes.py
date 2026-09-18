import pymupdf

def find_red_box_and_analyze(img_path, label):
    pix = pymupdf.Pixmap(img_path)
    w, h = pix.width, pix.height
    samples = pix.samples
    
    red_pixels = []
    for y in range(h):
        for x in range(w):
            idx = (y * w + x) * 3
            r, g, b = samples[idx], samples[idx+1], samples[idx+2]
            if r > 180 and g < 70 and b < 70 and y < 300:
                red_pixels.append((x, y))
                
    if not red_pixels:
        print(f"{label}: No red box found!")
        return
        
    min_x = min(p[0] for p in red_pixels)
    max_x = max(p[0] for p in red_pixels)
    min_y = min(p[1] for p in red_pixels)
    max_y = max(p[1] for p in red_pixels)
    
    print(f"=== {label} ===")
    print(f"Red box bounds: x=[{min_x}, {max_x}] (width={max_x - min_x}), y=[{min_y}, {max_y}] (height={max_y - min_y})")
    
    # Let's take horizontal line across the middle of the red box
    mid_y = (min_y + max_y) // 2
    # Sample brightness along this line from min_x to max_x
    brightness = []
    for x in range(min_x, max_x + 1):
        idx = (mid_y * w + x) * 3
        r, g, b = samples[idx], samples[idx+1], samples[idx+2]
        gray = int(0.299 * r + 0.587 * g + 0.114 * b)
        brightness.append(gray)
        
    # Find black bars:
    # A bar is dark (gray < threshold)
    threshold = 120
    is_black = [b < threshold for b in brightness]
    
    # Count transitions and measure bar span
    black_indices = [i for i, b in enumerate(is_black) if b]
    if black_indices:
        first_bar = min_x + black_indices[0]
        last_bar = min_x + black_indices[-1]
        barcode_pixel_width = last_bar - first_bar
        print(f"First bar at x={first_bar}, Last bar at x={last_bar}")
        print(f"Total barcode bar span: {barcode_pixel_width} pixels (Box width: {max_x - min_x})")
        
        # Count number of bars (transitions from white to black)
        transitions = 0
        in_bar = False
        bars = []
        curr_bar_len = 0
        curr_space_len = 0
        for b in is_black[black_indices[0] : black_indices[-1] + 1]:
            if b:
                if not in_bar:
                    transitions += 1
                    in_bar = True
                    if curr_space_len > 0:
                        bars.append(('S', curr_space_len))
                        curr_space_len = 0
                curr_bar_len += 1
            else:
                if in_bar:
                    in_bar = False
                    if curr_bar_len > 0:
                        bars.append(('B', curr_bar_len))
                        curr_bar_len = 0
                curr_space_len += 1
        if in_bar and curr_bar_len > 0:
            bars.append(('B', curr_bar_len))
            
        print(f"Number of black bars detected: {sum(1 for t, l in bars if t == 'B')}")
        print(f"Sequence of bars and spaces (first 20): {bars[:20]}")
        print(f"Total elements: {len(bars)}")
        
find_red_box_and_analyze(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762507285.jpg", "OK")
find_red_box_and_analyze(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762512623.jpg", "NG")
