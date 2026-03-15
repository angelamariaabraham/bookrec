import json
import os

def remove_book(title_substring):
    json_path = r'c:\Angela\bookrec\assets\books_data.json'
    
    if not os.path.exists(json_path):
        print(f"Error: {json_path} not found.")
        return

    with open(json_path, 'r', encoding='utf-8') as f:
        try:
            books = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}")
            return

    original_count = len(books)
    # Case insensitive search and removal
    books = [b for b in books if title_substring.lower() not in b.get('title', '').lower()]
    new_count = len(books)

    if original_count == new_count:
        print(f"No books found containing '{title_substring}'.")
        return

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(books, f, indent=2, ensure_ascii=False)
    
    print(f"Removed {original_count - new_count} book(s). Remaining: {new_count}")

if __name__ == "__main__":
    remove_book("hitchhiker")
