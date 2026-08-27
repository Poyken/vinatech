import fitz, json

doc = fitz.open('Drawing_ELV System_VINATECH_260615_v5.2.pdf')

def extract_sheet_labels(pno):
    page = doc[pno - 1]
    blocks = page.get_text('blocks')
    items = []
    for b in blocks:
        text = " ".join(b[4].split())
        if len(text) > 1:
            items.append({
                'box': [round(b[0], 1), round(b[1], 1), round(b[2], 1), round(b[3], 1)],
                'center': [round((b[0]+b[2])/2, 1), round((b[1]+b[3])/2, 1)],
                'text': text
            })
    return items

summary = {
    '1F_Net': extract_sheet_labels(13),
    '1.5F_Net': extract_sheet_labels(14),
    '2F_Net': extract_sheet_labels(15),
    '3F_Net': extract_sheet_labels(16),
    'Guardhouses': extract_sheet_labels(18),
    'MasterPlan': extract_sheet_labels(19),
    '1F_TAAC': extract_sheet_labels(25),
    '1.5F_TAAC': extract_sheet_labels(26),
    '2F_TAAC': extract_sheet_labels(27),
}

with open('deep_map_extracted.json', 'w', encoding='utf-8') as f:
    json.dump(summary, f, ensure_ascii=False, indent=2)

print('Extracted deep architectural labels to deep_map_extracted.json')
