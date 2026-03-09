import json
import re

def clean_advanced(text):
    if not text:
        return text
    
    # Remove control characters (\u0080-\u009F)
    text = re.sub(r'[\x80-\x9f]', '', text)
    
    # Fix missing spaces after punctuation (e.g., "DEATH.THE" -> "DEATH. THE")
    # Matches a letter, followed by ., ?, or !, optionally followed by quotes, followed immediately by an Uppercase letter or 'I'
    text = re.sub(r'([A-Za-z])([.?!]["\u201d\']?)([A-Z])', r'\1\2 \3', text)
    
    # Fix multiple spaces that might have been created
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text

def main():
    input_file = "assets/books_data.json"
    output_file = "assets/books_data.json"
    
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    cleaned_books = []
    
    for book in data:
        desc = book.get('description', '')
        
        # Drop books with extremely short descriptions
        if len(desc.split()) < 10:
            print(f"Dropping book with short description: {book.get('title')}")
            continue
            
        book['description'] = clean_advanced(desc)
        
        # also update normalized_description so the search isn't weirdly squished
        if 'normalized_description' in book and book['normalized_description']:
             # normalized description in this project includes title/author/genres string, so let's just use simple spacing fix
             book['normalized_description'] = re.sub(r'([A-Za-z])([.?!]["\']?)([A-Z])', r'\1\2 \3', book['normalized_description'])
             # since normalized_description is lowercased already, we should also space lowercase letters
             book['normalized_description'] = re.sub(r'([a-z])([.?!]["\']?)([a-z])', r'\1\2 \3', book['normalized_description'])

        cleaned_books.append(book)
            
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(cleaned_books, f, indent=2)
        
    print(f"Cleaned remaining books. Total books now: {len(cleaned_books)}")

if __name__ == "__main__":
    main()
