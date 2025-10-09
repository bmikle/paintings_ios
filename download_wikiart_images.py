#!/usr/bin/env python3
"""
Download images from WikiArt URLs and update JSON files with image filenames.
"""

import json
import csv
import re
import urllib.request
import urllib.error
import time
from pathlib import Path

def slugify(text):
    """Convert text to filename-safe slug."""
    text = text.lower()
    # Remove content in parentheses
    text = re.sub(r'\([^)]*\)', '', text)
    # Remove special characters
    text = re.sub(r'[^\w\s-]', '', text)
    # Replace spaces with hyphens
    text = re.sub(r'[\s_]+', '-', text)
    # Remove multiple hyphens
    text = re.sub(r'-+', '-', text)
    return text.strip('-')

def get_image_url_from_wikiart(page_url):
    """Extract the actual image URL from a WikiArt page."""
    try:
        req = urllib.request.Request(page_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            html = response.read().decode('utf-8')

        # Look for the main painting image URL
        # WikiArt uses patterns like: <img itemprop="image" src="...">
        # or in a data attribute

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
    # Read CSV with WikiArt URLs
    csv_file = 'paintings_wikiart_urls.csv'

    # Create output directory for images
    images_dir = Path('paintings_ios/Resources/Images')
    images_dir.mkdir(parents=True, exist_ok=True)

    print(f"Reading {csv_file}...")

    paintings_with_urls = []
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['wikiart_url']:  # Only process paintings with URLs
                paintings_with_urls.append(row)

    print(f"Found {len(paintings_with_urls)} paintings with WikiArt URLs")
    print(f"Images will be saved to: {images_dir}\n")

    # Download images
    downloaded = 0
    failed = 0

    for i, painting in enumerate(paintings_with_urls, 1):
        title = painting['title']
        artist = painting['artist']
        wikiart_url = painting['wikiart_url']

        # Create filename from artist and title
        filename_slug = slugify(f"{artist}-{title}")
        image_filename = f"{filename_slug}.jpg"
        output_path = images_dir / image_filename

        print(f"[{i}/{len(paintings_with_urls)}] {title} by {artist}")

        # Skip if already downloaded
        if output_path.exists():
            print(f"  ⏭️  Already exists: {image_filename}")
            painting['image_filename'] = image_filename
            downloaded += 1
            continue

        # Get image URL from WikiArt page
        print(f"  🔍 Fetching from: {wikiart_url}")
        image_url = get_image_url_from_wikiart(wikiart_url)

        if not image_url:
            print(f"  ❌ Could not find image URL")
            failed += 1
            painting['image_filename'] = ''
            continue

        print(f"  📥 Downloading image...")
        if download_image(image_url, output_path):
            file_size = output_path.stat().st_size / 1024  # KB
            print(f"  ✅ Saved: {image_filename} ({file_size:.1f} KB)")
            painting['image_filename'] = image_filename
            downloaded += 1
        else:
            print(f"  ❌ Download failed")
            failed += 1
            painting['image_filename'] = ''

        # Be nice to WikiArt's servers
        time.sleep(0.5)

        # Progress update every 25 images
        if i % 25 == 0:
            print(f"\n{'='*70}")
            print(f"Progress: {i}/{len(paintings_with_urls)}")
            print(f"Downloaded: {downloaded}, Failed: {failed}")
            print(f"{'='*70}\n")

    print(f"\n{'='*70}")
    print(f"IMAGE DOWNLOAD COMPLETE")
    print(f"{'='*70}")
    print(f"Successfully downloaded: {downloaded}")
    print(f"Failed: {failed}")
    print(f"{'='*70}\n")

    # Now update JSON files
    print("Updating JSON files with image filenames...\n")

    # Create a mapping of painting ID to image filename
    id_to_filename = {}
    for painting in paintings_with_urls:
        if painting.get('image_filename'):
            id_to_filename[painting['id']] = painting['image_filename']

    # Read all paintings from CSV to get the mapping
    all_paintings_map = {}
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            all_paintings_map[row['id']] = row

    # Update JSON files
    periods_dir = Path('paintings_ios/Resources/Data/Periods')
    updated_files = 0
    updated_paintings = 0

    for json_file in sorted(periods_dir.glob('*.json')):
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        modified = False
        for painting in data['paintings']:
            painting_id = painting['id']
            if painting_id in id_to_filename:
                painting['imageName'] = id_to_filename[painting_id]
                modified = True
                updated_paintings += 1

        if modified:
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"✅ Updated: {json_file.name}")
            updated_files += 1

    print(f"\n{'='*70}")
    print(f"JSON UPDATE COMPLETE")
    print(f"{'='*70}")
    print(f"Updated {updated_paintings} paintings in {updated_files} JSON files")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
