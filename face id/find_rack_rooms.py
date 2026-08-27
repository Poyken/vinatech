import fitz

doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def analyze_sheet_racks(pno, name):
    page = doc[pno-1]
    print(f"\n==================== {name} (Page {pno}) ====================")
    blocks = page.get_text('blocks')
    racks = []
    rooms = []
    
    for b in blocks:
        text = b[4].strip()
        t_upper = text.upper()
        if 'RACK' in t_upper or 'RACK_' in t_upper:
            racks.append(b)
        if any(k in t_upper for k in ['P.', 'ROOM', 'OFFICE', 'XƯỞNG', 'KHO', 'DOCK', 'CĂN TIN', 'SHOW ROOM', 'MIXER', 'EPS', 'LOCKER', 'GUARD', 'TRẠM', 'BẢO VỆ', 'E-PARKING', 'UTILITY', 'ULTILITY', 'LẮP RÁP', 'ĐỊNH HÌNH', 'ĐÓNG GÓI']):
            rooms.append(b)
            
    for r in racks:
        rx = (r[0] + r[2]) / 2
        ry = (r[1] + r[3]) / 2
        r_name = " ".join(r[4].split())
        
        # Find closest rooms
        closest_rooms = []
        for rm in rooms:
            rmx = (rm[0] + rm[2]) / 2
            rmy = (rm[1] + rm[3]) / 2
            dist = ((rx - rmx)**2 + (ry - rmy)**2)**0.5
            closest_rooms.append((dist, " ".join(rm[4].split()), (rmx, rmy)))
            
        closest_rooms.sort(key=lambda x: x[0])
        print(f"\n[RACK FOUND]: '{r_name}' at ({rx:.1f}, {ry:.1f})")
        print("  Nearby Rooms / Labels (within closest distance):")
        for d, rm_name, (rmx, rmy) in closest_rooms[:6]:
            print(f"    - dist {d:6.1f} pt -> '{rm_name}' at ({rmx:.1f}, {rmy:.1f})")

analyze_sheet_racks(13, "1F Network & PBX")
analyze_sheet_racks(15, "2F Network & PBX")
analyze_sheet_racks(18, "Guardhouse Network")
analyze_sheet_racks(19, "CCTV Master Plan")
analyze_sheet_racks(39, "Backbone Network Master Plan")
