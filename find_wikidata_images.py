#!/usr/bin/env python3
"""
Find images from Wikidata for paintings without WikiArt URLs.
"""

import csv
import json
import urllib.request
import urllib.parse
import time

def search_wikidata(title, artist):
    """Search Wikidata for a painting and return image URL."""
    try:
        # Build search query
        search_query = f"{title} {artist}"
        encoded_query = urllib.parse.quote(search_query)

        # Search Wikidata using wbsearchentities API
        search_url = f"https://www.wikidata.org/w/api.php?action=wbsearchentities&search={encoded_query}&language=en&limit=5&format=json"

        req = urllib.request.Request(search_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))

            if 'search' not in data or len(data['search']) == 0:
                return None

            # Try each search result
            for result in data['search']:
                entity_id = result['id']

                # Get entity data including image (P18)
                entity_url = f"https://www.wikidata.org/w/api.php?action=wbgetentities&ids={entity_id}&props=claims&format=json"

                req2 = urllib.request.Request(entity_url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req2, timeout=10) as response2:
                    entity_data = json.loads(response2.read().decode('utf-8'))

                    if 'entities' not in entity_data:
                        continue

                    entity = entity_data['entities'].get(entity_id, {})
                    claims = entity.get('claims', {})

                    # Check for image property (P18)
                    if 'P18' in claims and len(claims['P18']) > 0:
                        # Get image filename
                        image_filename = claims['P18'][0]['mainsnak']['datavalue']['value']

                        # Construct Wikimedia Commons URL
                        # Need to get actual file URL from Commons API
                        image_url = get_commons_image_url(image_filename)
                        if image_url:
                            return image_url

                    # Also try checking for Wikimedia Commons category (P373)
                    # or Commons gallery (P935) as fallback

            return None

    except Exception as e:
        print(f"    Error: {e}")
        return None

def get_commons_image_url(filename):
    """Get the actual image URL from Wikimedia Commons."""
    try:
        encoded_filename = urllib.parse.quote(f"File:{filename}")
        api_url = f"https://commons.wikimedia.org/w/api.php?action=query&titles={encoded_filename}&prop=imageinfo&iiprop=url&format=json"

        req = urllib.request.Request(api_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))

            pages = data.get('query', {}).get('pages', {})
            for page_id, page_data in pages.items():
                if 'imageinfo' in page_data and len(page_data['imageinfo']) > 0:
                    return page_data['imageinfo'][0]['url']

            return None

    except Exception as e:
        print(f"    Error getting Commons URL: {e}")
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
            if 'wikipedia_url' not in row:
                row['wikipedia_url'] = ''

    # Find paintings without WikiArt URLs
    paintings_without_urls = [row for row in rows if not row.get('wikiart_url', '').strip()]

    print(f"Found {len(paintings_without_urls)} paintings without WikiArt URLs")
    print(f"Searching Wikidata for images...\n")

    found_count = 0
    not_found_count = 0

    for i, row in enumerate(paintings_without_urls, 1):
        title = row['title']
        artist = row['artist']

        print(f"[{i}/{len(paintings_without_urls)}] {title} by {artist}")

        # Search Wikidata
        image_url = search_wikidata(title, artist)

        if image_url:
            print(f"  ✅ {image_url[:80]}...")
            row['wikipedia_url'] = image_url
            found_count += 1
        else:
            print(f"  ❌ Not found")
            not_found_count += 1

        time.sleep(0.3)  # Be nice to Wikidata's servers

        # Progress update every 25 paintings
        if i % 25 == 0:
            print(f"\n{'='*70}")
            print(f"Progress: {i}/{len(paintings_without_urls)}")
            print(f"Found: {found_count} ({found_count/i*100:.1f}%)")
            print(f"Not found: {not_found_count}")
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
    print(f"Found images: {found_count}/{len(paintings_without_urls)} ({found_count/len(paintings_without_urls)*100:.1f}%)")
    print(f"Not found: {not_found_count}/{len(paintings_without_urls)}")
    print(f"{'='*70}")

if __name__ == '__main__':
    main()
