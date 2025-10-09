#!/usr/bin/env python3
"""
Remove the duplicate Hockney image and clear imageName in JSON.
"""

import json
from pathlib import Path

def main():
    # Remove the duplicate image file
    duplicate_image = Path('paintings_ios/Resources/Images/david-hockney-peter-getting-out-of-nicks-pool.jpg')

    if duplicate_image.exists():
        duplicate_image.unlink()
        print(f"✅ Removed duplicate image: {duplicate_image.name}")

    # Update JSON to remove imageName for this painting
    painting_id = "d15c7e4f-8b50-4e3c-b9f0-62b7c3657a13"
    json_file = Path('paintings_ios/Resources/Data/Periods/pop_art.json')

    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    for painting in data['paintings']:
        if painting['id'] == painting_id:
            painting['imageName'] = ''
            print(f"✅ Cleared imageName for: {painting['title']}")
            break

    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Updated: {json_file.name}")

    print("\n" + "="*70)
    print("Note: WikiArt doesn't have the actual 'Peter Getting Out of Nick's Pool' image")
    print("It returned the same placeholder as 'A Bigger Splash'")
    print("="*70)

if __name__ == '__main__':
    main()
