import os

path = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\fn_VVT_getdatebyVendorLot_MergeCode.sql"

def fix_sql():
    try:
        # Read raw bytes to avoid encoding issues
        with open(path, 'rb') as f:
            content = f.read()

        # Remove BOM if present
        if content.startswith(b'\xef\xbb\xbf'):
            content = content[3:]

        # Step 1: Try to fix "double encoding"
        # Most of these garbled texts are UTF-8 bytes interpreted as Windows-1252
        try:
            # First, decode as UTF-8 to get the garbled string
            text = content.decode('utf-8')
            # Then, treat those characters as CP1252 bytes and decode again as UTF-8
            # This is the "magic" that fixes Chuyá»ƒn -> Chuyển
            fixed_text = text.encode('cp1252').decode('utf-8')
            if "Chuyển đổi" in fixed_text or "ngày" in fixed_text:
                text = fixed_text
        except Exception:
            # If magic fails, just use the UTF-8 decoded text
            text = content.decode('utf-8', errors='ignore')

        # Step 2: Clean up excessive blank lines
        lines = text.splitlines()
        cleaned_lines = []
        last_was_empty = False
        
        for line in lines:
            if line.strip() == "":
                if not last_was_empty:
                    cleaned_lines.append("")
                    last_was_empty = True
            else:
                cleaned_lines.append(line)
                last_was_empty = False

        # Step 3: Write back as UTF-8 with BOM
        with open(path, 'w', encoding='utf-8-sig') as f:
            f.write('\n'.join(cleaned_lines))
        
        print(f"Successfully fixed and cleaned: {path}")
        
    except Exception as e:
        print(f"Error occurred: {e}")

if __name__ == "__main__":
    fix_sql()
