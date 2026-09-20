import pymupdf

def analyze_box_content(img_path, box_rect, label):
    # box_rect: (x1, y1, x2, y2)
    pix = pymupdf.Pixmap(img_path)
    w, h = pix.width, pix.height
    samples = pix.samples
    
    x1, y1, x2, y2 = box_rect
    # take y slice inside the box avoiding red top and bottom borders
    mid_y = (y1 + y2) // 2
    
    # scan horizontally 5 pixels inside x1 and x2 to avoid vertical red lines
    bars = []
    curr_type = None
    curr_len = 0
    
    line = []
    for x in range(x1 + 8, x2 - 8):
        idx = (mid_y * w + x) * 3
        r, g, b = samples[idx], samples[idx+1], samples[idx+2]
        gray = int(0.299 * r + 0.587 * g + 0.114 * b)
        # Is it dark (bar) or light (space/paper)?
        is_bar = (gray < 110)
        line.append((x, is_bar, gray))
        
    # Find start and end of all bars
    bar_xs = [x for x, is_bar, _ in line if is_bar]
    if not bar_xs:
        print(f"{label}: No bars found!")
        return
        
    first_x = bar_xs[0]
    last_x = bar_xs[-1]
    total_bar_width = last_x - first_x
    
    # Count transitions inside [first_x, last_x]
    transitions = 0
    in_bar = True
    element_lengths = []
    curr_elem_len = 0
    curr_elem_type = 'B'
    
    for x, is_bar, gray in line:
        if x < first_x or x > last_x:
            continue
        elem_type = 'B' if is_bar else 'S'
        if elem_type == curr_elem_type:
            curr_elem_len += 1
        else:
            element_lengths.append((curr_elem_type, curr_elem_len))
            curr_elem_type = elem_type
            curr_elem_len = 1
    element_lengths.append((curr_elem_type, curr_elem_len))
    
    num_bars = sum(1 for t, l in element_lengths if t == 'B')
    num_spaces = sum(1 for t, l in element_lengths if t == 'S')
    
    print(f"=== {label} ===")
    print(f"Total bar span from first to last bar: {total_bar_width} pixels (within available box width {x2 - x1 - 16})")
    print(f"Margin Left (white space before first bar): {first_x - (x1 + 8)} px")
    print(f"Margin Right (white space after last bar): {(x2 - 8) - last_x} px")
    print(f"Number of black bars: {num_bars}, Number of spaces: {num_spaces}")
    print(f"Total elements: {len(element_lengths)}")
    print(f"Element sequence: {element_lengths}")

# For OK: red box was around x=[438, 716], y=[244, 396]
analyze_box_content(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762507285.jpg", (438, 244, 716, 396), "OK")

# For NG: red box was around x=[366, 684], y=[87, 247]
analyze_box_content(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762512623.jpg", (366, 87, 684, 247), "NG")
