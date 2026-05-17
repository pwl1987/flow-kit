import os

filepath = r'y:\pwl\code\plugins\3.6.0.md'

with open(filepath, 'rb') as f:
    raw = f.read()

print(f"File size: {len(raw)} bytes")
print(f"First 10 bytes: {raw[:10].hex(' ')}")

# Check for BOM
has_bom = raw[:3] == b'\xef\xbb\xbf'
print(f"Has UTF-8 BOM: {has_bom}")

# Strip BOM if present
if has_bom:
    raw_no_bom = raw[3:]
else:
    raw_no_bom = raw

# Try to decode as GBK (the original corruption path)
try:
    recovered = raw_no_bom.decode('gbk')
    print(f"GBK decode successful! {len(recovered)} chars")
    print(f"First line: {recovered.split(chr(10))[0][:100]}")
    
    # Check for replacement chars
    replacement_count = recovered.count('\ufffd')
    print(f"Replacement chars: {replacement_count}")
    
    # Write back as UTF-8 with BOM
    with open(filepath, 'w', encoding='utf-8-sig', newline='\n') as f:
        f.write(recovered)
    print("Written back with GBK→UTF-8 recovery")
except Exception as e:
    print(f"GBK decode failed: {e}")
    
    # Try with errors='replace'
    recovered = raw_no_bom.decode('gbk', errors='replace')
    replacement_count = recovered.count('\ufffd')
    print(f"GBK decode with replace: {replacement_count} replacement chars")
    print(f"First line: {recovered.split(chr(10))[0][:100]}")
    
    with open(filepath, 'w', encoding='utf-8-sig', newline='\n') as f:
        f.write(recovered)
    print("Written back with GBK→UTF-8 recovery (with replacements)")