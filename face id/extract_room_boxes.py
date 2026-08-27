import sys, fitz, json

sys.stdout.reconfigure(encoding='utf-8')
doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def extract_room_boxes(pno, name):
    page = doc[pno - 1]
    blocks = page.get_text('blocks')
    print(f"\n{'='*30} {name} (Page {pno}) {'='*30}")
    
    # We want to find all room labels and their positions
    rooms = []
    for b in blocks:
        text = " ".join(b[4].split())
        if any(k in text.upper() for k in [
            '101', '104', '105', '108', '109', '112', '113', '114', '115', '118', '120', '121', '128', '129', '131', '136', '137', '151',
            '201', '202', '203', '204', '206', '231', '232', '233', '234', '241',
            '301', '302', '303', '304', '305', '306', '311', '312', '313', '314', '315', '316', '317', '318', '321', '322', '323', '331', '332', '333', '341', '342',
            '401', '402', '411', '412', '413', '421',
            'RACK_MAIN', 'RACK_01', 'RACK_02', 'RACK_03', 'RACK_04', 'RACK_05', 'RACK_06', 'RACK_07', 'RACK_08', 'RACK_09',
            'KHO', 'DOCK', 'LẮP RÁP', 'ĐỊNH HÌNH', 'ĐÓNG GÓI', 'MIXER', 'CONTROL', 'PCCC', 'SHOW ROOM', 'CĂN TIN', 'IT ROOM', 'DIRECTOR', 'MEETING', 'OFFICE', 'GUARD'
        ]):
            if not any(k in text for k in ['VINHOMES', 'DOUL', 'CLIENT', 'HWANG', 'XUÂN HIẾU']):
                rooms.append({
                    'text': text,
                    'x0': round(b[0], 1),
                    'y0': round(b[1], 1),
                    'x1': round(b[2], 1),
                    'y1': round(b[3], 1),
                    'cx': round((b[0]+b[2])/2, 1),
                    'cy': round((b[1]+b[3])/2, 1)
                })
    
    rooms.sort(key=lambda r: (r['cx'], r['cy']))
    for r in rooms:
        print(f"  [{r['cx']:6.1f}, {r['cy']:6.1f}] -> {r['text']}")

extract_room_boxes(13, "1F Architectural Rooms")
extract_room_boxes(14, "1.5F Architectural Rooms")
extract_room_boxes(15, "2F Architectural Rooms")
extract_room_boxes(16, "3F Architectural Rooms")
