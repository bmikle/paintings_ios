#!/usr/bin/env python3
"""
Fix duplicate image filenames by including year in filename.
Re-download the affected paintings and update JSON files.
"""

import json
import csv
import re
import urllib.request
import time
from pathlib import Path

def slugify(text):
    """Convert text to filename-safe slug."""
    text = text.lower()
    text = re.sub(r'\([^)]*\)', '', text)
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_]+', '-', text)
    text = re.sub(r'-+', '-', text)
    return text.strip('-')

def get_image_url_from_wikiart(page_url):
    """Extract the actual image URL from a WikiArt page."""
    try:
        req = urllib.request.Request(page_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            html = response.read().decode('utf-8')

        # Pattern 1: itemprop="image"
        match = re.search(r'itemprop="image"[^>]+content="([^"]+)"', html)
        if match:
            return match.group(1)

        # Pattern 2: og:image meta tag
        match = re.search(r'property="og:image"[^>]+content="([^"]+)"', html)
        if match:
            return match.group(1)

        # Pattern 3: Look for large image in img tags
        match = re.search(r'<img[^>]+src="(https://uploads\d+\.wikiart\.org/images/[^"]+\.jpg[^"]*)"', html)
        if match:
            return match.group(1)

    except Exception as e:
        print(f"    Error extracting image URL: {e}")

    return None

def download_image(image_url, output_path):
    """Download an image from URL to output path."""
    try:
        req = urllib.request.Request(image_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=30) as response:
            data = response.read()
            with open(output_path, 'wb') as f:
                f.write(data)
        return True
    except Exception as e:
        print(f"    Error downloading: {e}")
        return False

def main():
    # Read CSV to find all paintings
    csv_file = 'paintings_wikiart_urls.csv'
    all_paintings = []

    print("Reading CSV...")
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['wikiart_url']:
                all_paintings.append(row)

    # Find paintings with duplicate filenames
    filename_to_paintings = {}
    for painting in all_paintings:
        filename_slug = slugify(f"{painting['artist']}-{painting['title']}")
        filename = f"{filename_slug}.jpg"

        if filename not in filename_to_paintings:
            filename_to_paintings[filename] = []
        filename_to_paintings[filename].append(painting)

    # Find duplicates
    duplicates = {k: v for k, v in filename_to_paintings.items() if len(v) > 1}

    print(f"Found {len(duplicates)} filename collisions affecting {sum(len(v) for v in duplicates.values())} paintings\n")

    if not duplicates:
        print("✅ No duplicates found!")
        return

    # Images directory
    images_dir = Path('paintings_ios/Resources/Images')

    # Process each duplicate group
    updated_paintings = {}  # Map painting ID to new filename

    for dup_filename, paintings in duplicates.items():
        print(f"Fixing collision: {dup_filename}")
        print(f"  Affects {len(paintings)} paintings:")

        for painting in paintings:
            print(f"    - {painting['title']} ({painting['year']}) by {painting['artist']}")

        # Generate unique filenames with year
        for painting in paintings:
            # New filename includes year
            new_filename_slug = slugify(f"{painting['artist']}-{painting['title']}-{painting['year']}")
            new_filename = f"{new_filename_slug}.jpg"
            new_output_path = images_dir / new_filename

            print(f"\n  Downloading: {new_filename}")
            print(f"    URL: {painting['wikiart_url']}")

            # Get image URL
            image_url = get_image_url_from_wikiart(painting['wikiart_url'])

            if not image_url:
                print(f"    ❌ Could not find image URL")
                continue

            # Download image
            if download_image(image_url, new_output_path):
                file_size = new_output_path.stat().st_size / 1024  # KB
                print(f"    ✅ Saved: {new_filename} ({file_size:.1f} KB)")
                updated_paintings[painting['id']] = new_filename
            else:
                print(f"    ❌ Download failed")

            time.sleep(0.5)

        # Remove old duplicate file
        old_path = images_dir / dup_filename
        if old_path.exists():
            old_path.unlink()
            print(f"\n  🗑️  Removed old file: {dup_filename}")

        print()

    print(f"\n{'='*70}")
    print(f"UPDATING JSON FILES")
    print(f"{'='*70}\n")

    # Update JSON files with new filenames
    periods_dir = Path('paintings_ios/Resources/Data/Periods')
    updated_count = 0

    for json_file in sorted(periods_dir.glob('*.json')):
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        modified = False
        for painting in data['paintings']:
            if painting['id'] in updated_paintings:
                painting['imageName'] = updated_paintings[painting['id']]
                modified = True
                updated_count += 1

        if modified:
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"✅ Updated: {json_file.name}")

    print(f"\n{'='*70}")
    print(f"✅ COMPLETE")
    print(f"{'='*70}")
    print(f"Fixed {len(duplicates)} filename collisions")
    print(f"Updated {updated_count} paintings in JSON files")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
