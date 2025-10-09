#!/usr/bin/env python3
"""
Remove old image files that weren't downloaded by the WikiArt script.
"""

import csv
import re
from pathlib import Path

def slugify(text):
    """Convert text to filename-safe slug."""
    text = text.lower()
    text = re.sub(r'\([^)]*\)', '', text)
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_]+', '-', text)
    text = re.sub(r'-+', '-', text)
    return text.strip('-')

def main():
    # Read CSV to get list of valid image filenames
    csv_file = 'paintings_wikiart_urls.csv'
    valid_filenames = set()

    print("Reading valid image filenames from CSV...")
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['wikiart_url']:  # Only paintings with URLs
                # Generate the expected filename
                filename_slug = slugify(f"{row['artist']}-{row['title']}")
                filename = f"{filename_slug}.jpg"
                valid_filenames.add(filename)

    print(f"Found {len(valid_filenames)} valid image filenames\n")

    # Get all files in Images directory
    images_dir = Path('paintings_ios/Resources/Images')
    all_images = list(images_dir.glob('*.jpg'))

    print(f"Found {len(all_images)} total image files in directory")

    # Find old files to remove
    old_files = []
    for image_file in all_images:
        if image_file.name not in valid_filenames:
            old_files.append(image_file)

    print(f"Found {len(old_files)} old files to remove\n")

    if not old_files:
        print("✅ No old files to remove!")
        return

    # Remove old files
    print("Removing old files...")
    for old_file in old_files:
        old_file.unlink()
        print(f"  ✅ Removed: {old_file.name}")

    print(f"\n{'='*70}")
    print(f"✅ Removed {len(old_files)} old image files")
    print(f"Remaining images: {len(all_images) - len(old_files)}")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
