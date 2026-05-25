import os
import re

slides_dir = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\slide\extracted\ppt\slides"

def replace_in_file(filename, old_text, new_text):
    filepath = os.path.join(slides_dir, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content.replace(old_text, new_text)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Updated {filename}")

# Slide 4
replace_in_file("slide4.xml", 
    "Inspect kiosks and remove suspected un-licensed/unauthorized software.", 
    "Inspect kiosks and remove unnecessary or conflicting software.")
replace_in_file("slide4.xml", 
    "Scanned all kiosk systems to identify unauthorized applications.", 
    "Scanned all kiosk systems to identify conflicting software such as eGalaxTouch Driver.")

# Slide 6
replace_in_file("slide6.xml", 
    "Detected GX Works p2 and GX Works p1 software requiring valid licenses.", 
    "Detected GX Works 2, GX Works 3, GX Developer, and MR Configurator2 software requiring valid licenses.")

# Slide 7
replace_in_file("slide7.xml", 
    "Detected MR Config2 software requiring a license and proceeded to remove it.", 
    "")
replace_in_file("slide7.xml", 
    " Control software requiring a license and proceeded to remove it.", 
    " Control FPWIN GR7S and PIDSX PLC USB-COM software requiring a license and proceeded to remove them.")

# Slide 8
replace_in_file("slide8.xml", 
    "Detected GX Works p2, GX Works p1, and Simple Motion software requiring valid licenses.", 
    "Detected GP-Pro EX (versions 4.08, 4.09) and CodeMeter Runtime Kit software requiring valid licenses.")

# Slide 11
replace_in_file("slide11.xml", 
    "Segregated warehouse management logic in the system into Raw Material (NVL) warehouse and Finished Goods warehouse databases.", 
    "Updated the Temperature & Humidity Monitoring System to include data filtering by Raw Material (NVL) and Finished Goods warehouse areas.")
