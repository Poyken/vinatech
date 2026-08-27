with open('dump_exact_sheets.txt', 'r', encoding='utf-8') as f:
    text = f.read()

p4_idx = text.find("==================== PAGE 4")
if p4_idx != -1:
    p5_idx = text.find("==================== PAGE 5", p4_idx)
    print(text[p4_idx:p5_idx])
