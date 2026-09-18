# Simulate Code 128 Auto Mode (DevExpress algorithm)
def encode_code128_auto_sim(text):
    # DevExpress / Zebra Code 128 Auto algorithm:
    # Starts in Code B (unless purely numeric 4+ digits, then Code C)
    tokens = []
    i = 0
    in_code_c = False
    
    # Check if starts with 4+ digits
    # For text like 'PK...', starts in Code B
    tokens.append('START_B')
    
    while i < len(text):
        # Look ahead for digits
        digits_ahead = 0
        while (i + digits_ahead < len(text)) and text[i + digits_ahead].isdigit():
            digits_ahead += 1
            
        if not in_code_c:
            if digits_ahead >= 4:
                # Switch to Code C
                tokens.append('CODE_C')
                in_code_c = True
                # consume pairs
                pairs = digits_ahead // 2
                for p in range(pairs):
                    tokens.append(text[i:i+2])
                    i += 2
            else:
                tokens.append(text[i])
                i += 1
        else:
            # currently in Code C
            if digits_ahead >= 2:
                tokens.append(text[i:i+2])
                i += 2
            else:
                # switch back to Code B
                tokens.append('CODE_B')
                in_code_c = False
                tokens.append(text[i])
                i += 1
                
    tokens.append('CHECK')
    tokens.append('STOP')
    
    # Each character in Code 128 is 6 elements (3 bars, 3 spaces), Stop is 7 elements
    num_elements = (len(tokens) - 1) * 6 + 7
    return tokens, num_elements

test_strings = [
    "PKQR1800254",
    "PKQR1800278",
    "PKQR1900142",
    "PKQR1900143",
    "PKQR1900119",
    "PKJP1700001",
    "VVQR013R072751",
    "VVQQ313R072743",
    "VEC3R0727QG",
    "ECVT30-357",
    "PKQQ3100001",
    "PKQQ310001",
    "PKQQ31001",
    "PKQQ3101",
    "PKQQ311",
    "PK000001",
    "PK00001",
    "PK0001",
    "PK001",
    "PK01",
    "PK1",
    "1",
    "51",
    "102"
]

print("=== Auto Mode Elements ===")
for s in test_strings:
    toks, elems = encode_code128_auto_sim(s)
    print(f"'{s}': {elems} elements | tokens: {toks}")
