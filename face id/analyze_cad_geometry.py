import sys, fitz

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def analyze_grid_axes(pno, name):
    page = doc[pno - 1]
    print(f"\n{'='*30} Grid Axes on {name} (Page {pno}) {'='*30}")
    blocks = page.get_text('blocks')
    
    x_axes = []
    y_axes = []
    
    for b in blocks:
        text = b[4].strip()
        # Look for 1X, 2X, ... 19X or 1 X, 2 X
        for i in range(1, 20):
            if text in [f"{i}X", f"{i}\nX", f"{i} X", f"X{i}", f"X\n{i}"]:
                x_axes.append((i, (b[0]+b[2])/2, (b[1]+b[3])/2, text.replace('\n', ' ')))
        # Look for 1Y, 2Y, ... 10Y or 1 Y, 2 Y
        for j in range(1, 11):
            if text in [f"{j}Y", f"{j}\nY", f"{j} Y", f"Y{j}", f"Y\n{j}"]:
                y_axes.append((j, (b[0]+b[2])/2, (b[1]+b[3])/2, text.replace('\n', ' ')))
                
    x_axes.sort(key=lambda x: x[1]) # sort by X position
    y_axes.sort(key=lambda y: y[2]) # sort by Y position
    
    print("--- X Axes (horizontal positions): ---")
    for ax, x, y, t in x_axes:
        print(f"  Axis {ax:2d}X: pos X={x:6.1f}, Y={y:6.1f}")
        
    print("--- Y Axes (vertical positions): ---")
    for ax, x, y, t in y_axes:
        print(f"  Axis {ax:2d}Y: pos X={x:6.1f}, Y={y:6.1f}")

analyze_grid_axes(13, "1F Network (Page 13)")
analyze_grid_axes(19, "CCTV Master Plan (Page 19)")
