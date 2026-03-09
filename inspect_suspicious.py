import json
import re

def clean_advanced_again(text):
    if not text:
        return text
        
    # Remove remaining instances of "Alternate cover" that wasn't caught
    text = re.sub(r'An alternate cover.*?here\.?', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Alternate cover.*?here\.?', '', text, flags=re.IGNORECASE)
    text = re.sub(r'Alternate Cover Edition.*?\.?', '', text, flags=re.IGNORECASE)
    text = re.sub(r'This is an alternate cover edition.*?\.?', '', text, flags=re.IGNORECASE)
    
    # Missing spaces after periods (if any remain)
    text = re.sub(r'([A-Za-z])([.?!]["\']?)([A-Z])', r'\1\2 \3', text)
    
    # Remove any weird brackets that are common in Goodreads scraping
    text = re.sub(r'\(less\)', '', text)
    text = re.sub(r'\[.*?\]', '', text)
    
    # Multiple spaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def inspect_suspicious(filename, outfile):
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    suspicious_keywords = ["librarian", "alternate cover", "isbn", "click here", "read more"]
    
    output_lines = []
    cleaned_books = []
    count = 0
    
    for book in data:
        desc = book.get('description', '')
        if not desc:
            cleaned_books.append(book)
            continue
            
        desc = clean_advanced_again(desc)
        book['description'] = desc
        
        # update normalized search string
        if 'normalized_description' in book and book['normalized_description']:
             book['normalized_description'] = clean_advanced_again(book['normalized_description'])
             
        cleaned_books.append(book)

        lower_desc = desc.lower()
        found = []
        for kw in suspicious_keywords:
            if kw in lower_desc:
                found.append(kw)
                
        if found:
            count += 1
            output_lines.append(f"Book: {book.get('title')} (Found: {', '.join(found)})")
            output_lines.append(f"Desc snippet: {desc[:200]}...\n")
            
    with open(outfile, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines))
        
    with open("assets/books_data.json", "w", encoding='utf-8') as f:
        json.dump(cleaned_books, f, indent=2)

if __name__ == "__main__":
    inspect_suspicious("assets/books_data.json", "suspicious_results.txt")
