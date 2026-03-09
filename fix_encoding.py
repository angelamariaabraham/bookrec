import json

def fix_mojibake(text):
    if not text:
        return text
    try:
        # If it was actually utf-8 but read as cp1252 and then saved as utf-8:
        return text.encode('cp1252').decode('utf-8')
    except (UnicodeEncodeError, UnicodeDecodeError):
        pass
    
    # Manual replacements for common cp1252 -> utf8 mojibake as fallback
    replacements = {
        'â€¢': '•',
        'â€“': '–',
        'â€”': '—',
        'â€˜': '‘',
        'â€™': '’',
        'â€œ': '“',
        'â€ ': '”',
        'â€¦': '…',
        'Ã©': 'é',
        'Ã ': 'à',
        'Ã¨': 'è',
        'Ã§': 'ç',
        'Ã±': 'ñ',
        'Ã³': 'ó',
        'Ã­': 'í',
        'Ã¡': 'á',
        'Ã¼': 'ü',
        'Â£': '£',
    }
    for k, v in replacements.items():
        text = text.replace(k, v)
        
    # Remove standalone Â that often appears in mojibake whitespace
    text = text.replace('Â ', ' ')
    text = text.replace('Â\xa0', '\xa0')
    return text

def main():
    file_path = 'c:/Angela/bookrec/assets/books_data.json'
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    for item in data:
        for key in ['title', 'author', 'description', 'normalized_description']:
            if key in item and isinstance(item[key], str):
                item[key] = fix_mojibake(item[key])
        
        # also check nested structures if needed, e.g. genres is a list or string?
        # looking at the db schema, genres is TEXT, meaning it might be a comma separated string.
        if 'genres' in item and isinstance(item['genres'], str):
            item['genres'] = fix_mojibake(item['genres'])

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        print("Successfully repaired books_data.json encoding.")

if __name__ == '__main__':
    main()
