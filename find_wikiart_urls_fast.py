#!/usr/bin/env python3
"""
Find actual WikiArt URLs for paintings - faster version with shorter timeouts.
"""

import json
import csv
import time
import urllib.request
import urllib.error
import re
import sys
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

def try_url(url):
    """Try URL with short timeout."""
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'}, method='HEAD')
        with urllib.request.urlopen(req, timeout=2) as response:
            return response.status == 200
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError):
        return False
    except:
        return False

def find_wikiart_url(artist, title, year):
    """Find WikiArt URL by trying common patterns."""
    artist_slug = slugify(artist)
    title_slug = slugify(title)

    # Try common URL patterns
    patterns = [
        f"https://www.wikiart.org/en/{artist_slug}/{title_slug}",
        f"https://www.wikiart.org/en/{artist_slug}/{title_slug}-{year}",
        f"https://www.wikiart.org/en/{artist_slug}/the-{title_slug}",
        f"https://www.wikiart.org/en/{artist_slug}/the-{title_slug}-{year}",
    ]

    for url in patterns:
        if try_url(url):
            return url

    return None

def main():
    # Read all paintings
    periods_dir = Path('paintings_ios/Resources/Data/Periods')
    all_paintings = []

    print("Loading paintings...", flush=True)
    for json_file in sorted(periods_dir.glob('*.json')):
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            all_paintings.extend(data['paintings'])

    print(f"Total paintings: {len(all_paintings)}\n", flush=True)
    print("Searching WikiArt...\n", flush=True)

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

        for i, painting in enumerate(all_paintings, 1):
            title = painting['title'][:50]  # Truncate for display
            print(f"[{i}/{len(all_paintings)}] {title}...", end=' ', flush=True)

            url = find_wikiart_url(painting['artist'], painting['title'], painting['year'])

            if url:
                print(f"✅", flush=True)
                found_count += 1
            else:
                print(f"❌", flush=True)

            writer.writerow({
                'id': painting['id'],
                'title': painting['title'],
                'artist': painting['artist'],
                'year': painting['year'],
                'period': painting['period'],
                'museum': painting['museum'],
                'location': painting['location'],
                'imageName': painting.get('imageName', ''),
                'wikiart_url': url or ''
            })

            # Smaller delay
            time.sleep(0.1)

            # Progress updates
            if i % 50 == 0:
                print(f"\nProgress: {i}/{len(all_paintings)} | Found: {found_count} ({found_count/i*100:.1f}%)\n", flush=True)

    print(f"\n{'='*70}")
    print(f"✅ Done! CSV created: {output_file}")
    print(f"Found: {found_count}/{len(all_paintings)} ({found_count/len(all_paintings)*100:.1f}%)")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
