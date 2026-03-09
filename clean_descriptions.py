import json
import re

def clean_description(text):
    if not text:
        return text
    
    # Remove Librarian's note / Alternate cover edition text
    text = re.sub(r"Librarian's note:.*?here\.?", "", text, flags=re.IGNORECASE)
    text = re.sub(r"Librarian note:.*?here\.?", "", text, flags=re.IGNORECASE)
    text = re.sub(r"Alternate cover edition.*?ISBN\s*[\d-]+\.?", "", text, flags=re.IGNORECASE)
    text = re.sub(r"An alternate cover edition can be found here\.?", "", text, flags=re.IGNORECASE)
    text = re.sub(r"You can find an alternative cover edition for this ISBN here and here\.?", "", text, flags=re.IGNORECASE)
    text = re.sub(r"Alternate cover for this ISBN can be found here\.?", "", text, flags=re.IGNORECASE)
    
    # Fix bad encodings
    text = text.replace("â€", '"')
    text = text.replace("â€™", "'")
    text = text.replace("â€œ", '"')
    text = text.replace("â€?", '"')
    text = text.replace("\u00e2\u20ac\u2122", "'") # â€™
    text = text.replace("\u00e2\u20ac\u02dc", "'") # â€˜
    text = text.replace("\u00e2\u20ac\u201c", "-") # â€œ
    text = text.replace("\u00e2\u20ac\u201d", "-") # â€
    text = text.replace("\u00e2\u20ac\u00a6", "...") # â€¦
    text = text.replace("ï¿½", "'")
    text = text.replace("Ã©", "é")
    text = text.replace("Ã", "á")

    # Clean up multiple spaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def main():
    input_file = "assets/books_data.json"
    output_file = "assets/books_data.json"
    
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    for book in data:
        if 'description' in book and book['description']:
            book['description'] = clean_description(book['description'])
            
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
        
    print(f"Cleaned {len(data)} books in {output_file}")

if __name__ == "__main__":
    main()
