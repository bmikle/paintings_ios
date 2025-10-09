#!/usr/bin/env python3
"""
Remove de Kooning placeholder images and update CSV/JSON to reflect unavailability.
"""

import json
import csv
from pathlib import Path

def main():
    # Remove the placeholder images
    placeholder_images = [
        'willem-de-kooning-woman-i.jpg',
        'willem-de-kooning-excavation.jpg',
        'willem-de-kooning-gotham-news.jpg'
    ]

    images_dir = Path('paintings_ios/Resources/Images')
    removed_count = 0

    for img_name in placeholder_images:
        img_path = images_dir / img_name
        if img_path.exists():
            img_path.unlink()
            print(f"✅ Removed placeholder image: {img_name}")
            removed_count += 1

    # Update CSV to remove WikiArt URLs
    csv_file = 'paintings_wikiart_urls.csv'
    painting_ids = [
        "db3c8c4e-80d2-4b62-9b0c-19f02879bb85",  # Woman I
        "f27a6c63-80f0-47dc-9fd1-3a52cf7870cc",  # Excavation
        "e12c68b8-60b8-46d1-8ed1-0a9d69c1b6cb"   # Gotham News
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

    print(f"✅ Updated CSV: Removed WikiArt URLs for de Kooning paintings")

    # Update JSON to clear imageNames
    json_file = Path('paintings_ios/Resources/Data/Periods/abstract_expressionism.json')

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
    print(f"Removed {removed_count} placeholder images for:")
    print("  - Woman I (1950)")
    print("  - Excavation (1950)")
    print("  - Gotham News (1955)")
    print("\nAll three paintings marked as unavailable in CSV and JSON")
    print("="*70)

if __name__ == '__main__':
    main()
