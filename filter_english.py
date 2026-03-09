import json
import re

def is_mostly_english(text):
    if not text:
        return True
    
    # Remove all non-letter characters
    only_letters = re.sub(r'[^a-zA-Z\s]', '', text).replace(' ', '')
    total_chars = len(text.replace(' ', ''))
    
    if total_chars == 0:
        return True
        
    return len(only_letters) >= (total_chars * 0.4) # at least 40% basic latin

def main():
    file_path = 'c:/Angela/bookrec/assets/books_data.json'
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    original_count = len(data)
    filtered_data = []

    for item in data:
        # Check title, author, and description
        title_ok = is_mostly_english(item.get('title', ''))
        author_ok = is_mostly_english(item.get('author', ''))
        desc_ok = is_mostly_english(item.get('description', ''))
        
        if title_ok and author_ok and desc_ok:
            filtered_data.append(item)

    print(f"Original books: {original_count}")
    print(f"Filtered books: {len(filtered_data)}")
    print(f"Removed {original_count - len(filtered_data)} non-English books.")

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(filtered_data, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    main()
