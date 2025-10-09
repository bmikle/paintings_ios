#!/usr/bin/env python3
"""
Find actual WikiArt URLs for all paintings using WikiArt's search API.
Uses only standard library - no external dependencies.
"""

import json
import csv
import time
import urllib.request
import urllib.parse
import re
from pathlib import Path

def slugify(text):
    """Convert text to WikiArt-compatible URL slug."""
    text = text.lower()
    # Remove content in parentheses
    text = re.sub(r'\([^)]*\)', '', text)
    # Remove special characters except spaces and hyphens
    text = re.sub(r'[^\w\s-]', '', text)
    # Replace spaces and underscores with hyphens
    text = re.sub(r'[\s_]+', '-', text)
    # Remove multiple hyphens
    text = re.sub(r'-+', '-', text)
    return text.strip('-')

def try_wikiart_url(url):
    """Try to access a WikiArt URL and see if it exists."""
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            if response.status == 200:
                return True
    except:
        pass
    return False

def find_wikiart_url(artist, title, year):
    """Find WikiArt URL for a painting by trying common patterns."""
    artist_slug = slugify(artist)
    title_slug = slugify(title)

    # Try various URL patterns that WikiArt uses
    patterns = [
        # Without year
        f"https://www.wikiart.org/en/{artist_slug}/{title_slug}",
        # With year at end
        f"https://www.wikiart.org/en/{artist_slug}/{title_slug}-{year}",
        # With "the-" prefix
        f"https://www.wikiart.org/en/{artist_slug}/the-{title_slug}",
        f"https://www.wikiart.org/en/{artist_slug}/the-{title_slug}-{year}",
    ]

    for url in patterns:
        if try_wikiart_url(url):
            return url

    return None

def main():
    # Read all paintings
    periods_dir = Path('paintings_ios/Resources/Data/Periods')
    all_paintings = []

    for json_file in sorted(periods_dir.glob('*.json')):
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            all_paintings.extend(data['paintings'])

    print(f"Total paintings: {len(all_paintings)}")
    print("\nSearching WikiArt for URLs...")
    print("This will take a while as we try multiple URL patterns for each painting.\n")

    # Create CSV with results
    output_file = 'paintings_wikiart_urls.csv'

    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = [
            'id', 'title', 'artist', 'year', 'period',
            'museum', 'location', 'imageName', 'wikiart_url'
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        found_count = 0
        not_found_count = 0

        for i, painting in enumerate(all_paintings, 1):
            print(f"[{i}/{len(all_paintings)}] {painting['title']} by {painting['artist']}")

            url = find_wikiart_url(painting['artist'], painting['title'], painting['year'])

            if url:
                print(f"  ✅ {url}")
                found_count += 1
            else:
                print(f"  ❌ Not found on WikiArt")
                not_found_count += 1

            row = {
                'id': painting['id'],
                'title': painting['title'],
                'artist': painting['artist'],
                'year': painting['year'],
                'period': painting['period'],
                'museum': painting['museum'],
                'location': painting['location'],
                'imageName': painting.get('imageName', ''),
                'wikiart_url': url if url else ''
            }

            writer.writerow(row)

            # Be nice to WikiArt's servers - small delay
            time.sleep(0.3)

            # Progress update every 25 paintings
            if i % 25 == 0:
                print(f"\n{'='*70}")
                print(f"Progress: {i}/{len(all_paintings)} processed")
                print(f"Found: {found_count} ({found_count/i*100:.1f}%)")
                print(f"Not found: {not_found_count}")
                print(f"{'='*70}\n")

    print(f"\n{'='*70}")
    print(f"FINAL RESULTS")
    print(f"{'='*70}")
    print(f"✅ CSV file created: {output_file}")
    print(f"Found: {found_count}/{len(all_paintings)} ({found_count/len(all_paintings)*100:.1f}%)")
    print(f"Not found: {not_found_count}/{len(all_paintings)}")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
