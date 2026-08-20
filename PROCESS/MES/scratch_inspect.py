import xml.etree.ElementTree as ET

tree = ET.parse('scratch_HY_FinishGoods.xml')
root = tree.getroot()
print("Root tag:", root.tag)
for child in root:
    print(f"Child tag: {child.tag}, text preview: {str(child.text)[:50] if child.text else ''}, len(children)={len(child)}")
