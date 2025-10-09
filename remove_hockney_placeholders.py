#!/usr/bin/env python3
"""
Remove Hockney placeholder images and update CSV/JSON to reflect unavailability.
"""

import json
import csv
from pathlib import Path

def main():
    # Remove the placeholder image
    placeholder_image = Path('paintings_ios/Resources/Images/david-hockney-a-bigger-splash.jpg')

    if placeholder_image.exists():
        placeholder_image.unlink()
        print(f"✅ Removed placeholder image: {placeholder_image.name}")

    # Update CSV to remove WikiArt URLs for both paintings
    csv_file = 'paintings_wikiart_urls.csv'
    painting_ids = [
        "d9302f03-9ff7-4200-bb58-1e9c6613a6cb",  # A Bigger Splash
        "d15c7e4f-8b50-4e3c-b9f0-62b7c3657a13"   # Peter Getting Out of Nick's Pool
    ]

    rows = []
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['id'] in painting_ids:
                row['wikiart_url'] = ''  # Clear the URL
            rows.append(row)

    # Write updated CSV
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        if rows:
            writer = csv.DictWriter(f, fieldnames=rows[0].keys())
            writer.writeheader()
            writer.writerows(rows)

    print(f"✅ Updated CSV: Removed WikiArt URLs for both Hockney paintings")

    # Update JSON to clear imageNames
    json_file = Path('paintings_ios/Resources/Data/Periods/pop_art.json')

    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    updated_count = 0
    for painting in data['paintings']:
        if painting['id'] in painting_ids:
            painting['imageName'] = ''
            print(f"✅ Cleared imageName for: {painting['title']}")
            updated_count += 1

    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Updated: {json_file.name}")

    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print("Removed placeholder images for:")
    print("  - A Bigger Splash (1967)")
    print("  - Peter Getting Out of Nick's Pool (1966)")
    print("\nBoth paintings marked as unavailable in CSV and JSON")
    print("="*70)

if __name__ == '__main__':
    main()
