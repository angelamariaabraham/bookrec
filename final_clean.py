import json
import re

def final_isbn_clean(text):
    if not text:
        return text
        
    # Remove ISBN-related lines that take many forms
    text = re.sub(r'ISBN\s*\d+\s*moved to this edition\.?\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Also see: s for this ISBN ACE #\d+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Alternative Cover/publisher Edition ISBN \d+ \(ISBN13:\s*\d+\)\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'\(ISBN13:\s*\d+\)\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'alternate edition for ISBN \d+/\d+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'original cover of ISBN \d+/\d+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Alternate Cove[r]? edition for ISBN \d+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Alternative cover for ISBN: [\d-]+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'This is the original cover edition of ISBN: \d+.*?Winner', 'Winner', text, flags=re.IGNORECASE)
    text = re.sub(r'alternate cover for ISBN \d+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Librarian[s]?[\']? note:.*?of \d+\.\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Librarian[s]?[\']? Note: Alternate[ -]cover edition for ISBN [0-9xX/ \-]+\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'This is a previously published edition of ISBN13: \d+\.\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'This is a previously published edition of ISBN \d+\.\s*', '', text, flags=re.IGNORECASE)
    text = re.sub(r'This is a previously published cover edition of ISBN \d+\.\s*', '', text, flags=re.IGNORECASE)

    # Some books have "Librarian Note:" followed by the actual text. Let's just remove the prefix.
    text = re.sub(r'^Librarian Note:\s*', '', text, flags=re.IGNORECASE)
    
    return text.strip()

def apply_final_clean(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    for book in data:
        desc = book.get('description', '')
        if desc:
            book['description'] = final_isbn_clean(desc)
            
        if 'normalized_description' in book and book['normalized_description']:
            book['normalized_description'] = final_isbn_clean(book['normalized_description'])
            
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    apply_final_clean("assets/books_data.json")
