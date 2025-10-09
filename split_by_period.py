#!/usr/bin/env python3
import json
import os
from collections import defaultdict

# Read the main paintings.json
with open('paintings_ios/Resources/Data/paintings.json', 'r') as f:
    data = json.load(f)

# Group paintings by period
paintings_by_period = defaultdict(list)
for painting in data['paintings']:
    # Add empty imageName field if missing
    if 'imageName' not in painting:
        painting['imageName'] = ""

    period = painting['period']
    paintings_by_period[period].append(painting)

# Create output directory if needed
output_dir = 'paintings_ios/Resources/Data/Periods'
os.makedirs(output_dir, exist_ok=True)

# Write each period to a separate file
for period, paintings in sorted(paintings_by_period.items()):
    # Convert period name to snake_case filename
    filename = period.lower().replace(' / ', '_').replace(' ', '_') + '.json'
    filepath = os.path.join(output_dir, filename)

    output = {'paintings': paintings}

    with open(filepath, 'w') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"✅ Created {filename} with {len(paintings)} paintings")

print(f"\n📁 All files created in {output_dir}/")
print(f"📊 Total: {len(data['paintings'])} paintings across {len(paintings_by_period)} periods")
