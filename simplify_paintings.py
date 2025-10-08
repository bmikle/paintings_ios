#!/usr/bin/env python3
import json

# Read current paintings
with open('paintings_ios/Resources/Data/paintings.json', 'r') as f:
    data = json.load(f)

# Simplify each painting
simplified_paintings = []
for painting in data['paintings']:
    simplified = {
        'id': painting['id'],
        'title': painting['title'],
        'artist': painting['artist'],
        'year': painting['year'],
        'period': painting['period'],
        'imageName': painting['imageName'],
        'museum': painting['museum'],
        'location': painting['location']
    }
    simplified_paintings.append(simplified)

# Write simplified version
output = {'paintings': simplified_paintings}
with open('paintings_ios/Resources/Data/paintings.json', 'w') as f:
    json.dump(output, f, indent=2)

print(f"✅ Simplified {len(simplified_paintings)} paintings")
print(f"Removed fields: description, dimensions, medium, wikiURL")
