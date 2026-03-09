import json
import re

def fix_image_url(url):
    if not url:
        return url
    
    # 1. Strip the dimension markers such as ._SY475_ or _SX318_ or SY475_ 
    # Example raw issue: 52775419SY475_.jpg
    cleaned_url = re.sub(r'\.?_?S[XY]\d+_?', '', url)
    
    # 2. Swap the compressed subdomain for the uncompressed one
    cleaned_url = cleaned_url.replace('compressed.photo.goodreads.com', 'photo.goodreads.com')
    
    return cleaned_url

def main():
    file_path = 'c:/Angela/bookrec/assets/books_data.json'
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    changed_count = 0

    for item in data:
        old_url = item.get('cover_image_url')
        if old_url:
            new_url = fix_image_url(old_url)
            if old_url != new_url:
                item['cover_image_url'] = new_url
                changed_count += 1
                
    print(f"Fixed {changed_count} image URLs.")

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    main()
