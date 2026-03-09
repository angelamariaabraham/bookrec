import json
import re
from collections import Counter

def analyze_dataset(filename, outfile):
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    html_tags_count = 0
    urls_count = 0
    short_desc_count = 0
    missing_fields_count = 0
    weird_chars = Counter()
    
    for i, book in enumerate(data):
        desc = book.get('description', '')
        
        if not book.get('title') or not book.get('author') or not book.get('cover_url') or not desc:
            missing_fields_count += 1
            
        if desc:
            if re.search(r'<[^>]+>', desc):
                html_tags_count += 1
            
            if re.search(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', desc):
                urls_count += 1
                
            if len(desc.split()) < 10:
                short_desc_count += 1
                
            for char in desc:
                if ord(char) > 127:
                    weird_chars[char] += 1
                    
    results = {
        "total_books": len(data),
        "html_tags_count": html_tags_count,
        "urls_count": urls_count,
        "short_desc_count": short_desc_count,
        "missing_fields_count": missing_fields_count,
        "top_weird_chars": [{"char": k, "unicode": f"U+{ord(k):04X}", "count": v} for k, v in weird_chars.most_common(50)]
    }
    
    with open(outfile, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    analyze_dataset("assets/books_data.json", "analysis_results.json")
