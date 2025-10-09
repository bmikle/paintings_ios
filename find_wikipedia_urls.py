#!/usr/bin/env python3
"""
Find Wikipedia image URLs for paintings without WikiArt URLs.
"""

import csv
import json
import urllib.request
import urllib.parse
import time
import re
from pathlib import Path

def search_wikipedia(painting_title, artist):
    """Search Wikipedia for a painting and return the page title."""
    try:
        # Search Wikipedia
        search_query = f"{painting_title} {artist}"
        encoded_query = urllib.parse.quote(search_query)
        search_url = f"https://en.wikipedia.org/w/api.php?action=opensearch&search={encoded_query}&limit=5&format=json"

        req = urllib.request.Request(search_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))

            # data format: [query, [titles], [descriptions], [urls]]
            if len(data) > 3 and len(data[1]) > 0:
                # Return first result title
                return data[1][0]

    except Exception as e:
        print(f"    Error searching Wikipedia: {e}")

    return None

def get_wikipedia_image_url(page_title):
    """Get the main image URL from a Wikipedia page."""
    try:
        # Get page info including images
        encoded_title = urllib.parse.quote(page_title)
        api_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={encoded_title}&prop=pageimages|images&format=json&pithumbsize=1000"

        req = urllib.request.Request(api_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))

            pages = data.get('query', {}).get('pages', {})
            for page_id, page_data in pages.items():
                # Try to get the main thumbnail
                if 'thumbnail' in page_data:
                    return page_data['thumbnail']['source']

                # Try to get images list and fetch the first one
                if 'images' in page_data and len(page_data['images']) > 0:
                    # Get first image filename
                    first_image = page_data['images'][0]['title']

                    # Get image URL
                    image_api_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={urllib.parse.quote(first_image)}&prop=imageinfo&iiprop=url&format=json"
                    req2 = urllib.request.Request(image_api_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req2, timeout=10) as response2:
                        img_data = json.loads(response2.read().decode('utf-8'))
                        img_pages = img_data.get('query', {}).get('pages', {})
                        for img_page_id, img_page_data in img_pages.items():
                            if 'imageinfo' in img_page_data and len(img_page_data['imageinfo']) > 0:
                                return img_page_data['imageinfo'][0]['url']

    except Exception as e:
        print(f"    Error getting Wikipedia image: {e}")

    return None

def main():
    # Read CSV
    csv_file = 'paintings_wikiart_urls.csv'
    rows = []

    print("Reading CSV...")
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        for row in reader:
            rows.append(row)

    # Add wikipedia_url column if not exists
    if 'wikipedia_url' not in fieldnames:
        fieldnames = list(fieldnames) + ['wikipedia_url']
        for row in rows:
            row['wikipedia_url'] = ''

    # Find paintings without WikiArt URLs
    paintings_without_urls = [row for row in rows if not row.get('wikiart_url', '').strip()]

    print(f"Found {len(paintings_without_urls)} paintings without WikiArt URLs")
    print(f"Searching Wikipedia for images...\n")

    found_count = 0
    not_found_count = 0

    for i, row in enumerate(paintings_without_urls, 1):
        title = row['title']
        artist = row['artist']

        print(f"[{i}/{len(paintings_without_urls)}] {title} by {artist}")

        # Search Wikipedia
        wiki_page = search_wikipedia(title, artist)

        if not wiki_page:
            print(f"  ❌ Not found on Wikipedia")
            not_found_count += 1
            time.sleep(0.5)
            continue

        print(f"  🔍 Found page: {wiki_page}")

        # Get image URL
        image_url = get_wikipedia_image_url(wiki_page)

        if image_url:
            print(f"  ✅ Image URL: {image_url[:80]}...")
            row['wikipedia_url'] = image_url
            found_count += 1
        else:
            print(f"  ❌ No image found")
            not_found_count += 1

        time.sleep(0.5)  # Be nice to Wikipedia's servers

        # Progress update every 25 paintings
        if i % 25 == 0:
            print(f"\n{'='*70}")
            print(f"Progress: {i}/{len(paintings_without_urls)}")
            print(f"Found: {found_count}, Not found: {not_found_count}")
            print(f"{'='*70}\n")

    # Write updated CSV
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"\n{'='*70}")
    print(f"FINAL RESULTS")
    print(f"{'='*70}")
    print(f"✅ CSV updated: {csv_file}")
    print(f"Found Wikipedia images: {found_count}/{len(paintings_without_urls)}")
    print(f"Not found: {not_found_count}/{len(paintings_without_urls)}")
    print(f"Success rate: {found_count/len(paintings_without_urls)*100:.1f}%")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
