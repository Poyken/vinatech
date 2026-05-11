import os

def clean_sql_file(input_path):
    try:
        # Read the file. sqlcmd -f 65001 outputs UTF-8.
        # If it shows as "Chuyá»ƒn", it's UTF-8 bytes being read as ANSI.
        # We read as latin-1 to get the raw bytes, then decode as utf-8.
        with open(input_path, 'rb') as f:
            raw_bytes = f.read()
        
        try:
            # Try decoding as UTF-8 first
            text = raw_bytes.decode('utf-8')
            # If it contains "á»ƒ", it's double-encoded or interpreted wrong.
            # But wait, if we decode as utf-8 and see "á»ƒ", it means the SOURCE 
            # already had those literal characters. 
            # In our case, the RAW file from sqlcmd -f 65001 SHOULD be correct utf-8.
        except UnicodeDecodeError:
            text = raw_bytes.decode('latin-1')

        # Fix the common "UTF-8 interpreted as ANSI" artifacts if they exist
        # This is a safety net
        if 'Chuyá»ƒn' in text or 'ngÃ y' in text:
            text = text.encode('latin-1').decode('utf-8')

        # Remove excessive blank lines (keep at most one blank line between blocks)
        lines = text.splitlines()
        cleaned_lines = []
        last_was_empty = False
        
        for line in lines:
            stripped = line.strip()
            if stripped == '':
                if not last_was_empty:
                    cleaned_lines.append('')
                    last_was_empty = True
            else:
                cleaned_lines.append(line)
                last_was_empty = False
        
        # Write back as UTF-8 with BOM
        with open(input_path, 'w', encoding='utf-8-sig') as f:
            f.write('\n'.join(cleaned_lines))
            
        print(f"Successfully cleaned and fixed encoding for {input_path}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    clean_sql_file('fn_VVT_getdatebyVendorLot_MergeCode.sql')
