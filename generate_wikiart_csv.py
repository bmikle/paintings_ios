#!/usr/bin/env python3
"""
Generate a CSV file with WikiArt URLs for all paintings.
WikiArt URLs follow the pattern: https://www.wikiart.org/en/[artist-slug]/[painting-slug]
"""

import json
import csv
import os
import re
from pathlib import Path

def slugify(text):
    """Convert text to WikiArt-compatible URL slug."""
    # Convert to lowercase
    text = text.lower()
    # Remove special characters and replace spaces/punctuation with hyphens
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_]+', '-', text)
    text = re.sub(r'-+', '-', text)
    # Remove leading/trailing hyphens
    text = text.strip('-')
    return text

def generate_wikiart_url(artist, title, year):
    """Generate a WikiArt URL for a painting."""
    artist_slug = slugify(artist)
    title_slug = slugify(title)

    # WikiArt often includes the year in the URL
    base_url = f"https://www.wikiart.org/en/{artist_slug}/{title_slug}"

    # Return both with and without year for manual verification
    return {
        'url': base_url,
        'url_with_year': f"{base_url}-{year}"
    }

def main():
    # Path to period JSON files
    periods_dir = Path('paintings_ios/Resources/Data/Periods')

    # Collect all paintings
    all_paintings = []

    for json_file in sorted(periods_dir.glob('*.json')):
        print(f"Reading {json_file.name}...")
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            all_paintings.extend(data['paintings'])

    print(f"\nTotal paintings: {len(all_paintings)}")

    # Generate CSV
    output_file = 'paintings_wikiart_urls.csv'

    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = [
            'id', 'title', 'artist', 'year', 'period',
            'museum', 'location', 'imageName',
            'wikiart_url', 'wikiart_url_with_year'
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()

        for painting in all_paintings:
            urls = generate_wikiart_url(
                painting['artist'],
                painting['title'],
                painting['year']
            )

            row = {
                'id': painting['id'],
                'title': painting['title'],
                'artist': painting['artist'],
                'year': painting['year'],
                'period': painting['period'],
                'museum': painting['museum'],
                'location': painting['location'],
                'imageName': painting.get('imageName', ''),
                'wikiart_url': urls['url'],
                'wikiart_url_with_year': urls['url_with_year']
            }

            writer.writerow(row)

    print(f"\n✅ CSV file created: {output_file}")
    print(f"   Contains {len(all_paintings)} paintings with WikiArt URLs")
    print(f"\nNote: URLs are generated based on WikiArt's standard pattern.")
    print(f"      Some URLs may need manual verification or adjustment.")
    print(f"      Both versions (with/without year) are provided for flexibility.")

if __name__ == '__main__':
    main()
