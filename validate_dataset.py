import json
import re
from collections import Counter

def validate_dataset(filename, outfile):
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    issues = {
        "multiple_spaces": 0,
        "leading_trailing_spaces": 0,
        "html_remnants": 0,
        "bracket_remnants": 0,
        "suspicious_patterns": 0,
        "uncapitalized_sentences": 0,
        "missing_punctuation_at_end": 0,
        "unusual_characters": Counter()
    }
    
    acceptable_chars_regex = re.compile(r'[^\x20-\x7E\u00C0-\u00FF\u2018-\u201D\u2013\u2014\u2026\n\t]')
    
    suspicious_keywords = ["librarian", "alternate cover", "isbn", "click here", "read more"]
    
    for book in data:
        desc = book.get('description', '')
        if not desc:
            continue
            
        if re.search(r' {2,}', desc):
            issues["multiple_spaces"] += 1
            
        if desc != desc.strip():
            issues["leading_trailing_spaces"] += 1
            
        if re.search(r'<[^>]+>|&[a-z]+;|\[.*?\]\(.*?\)', desc):
            issues["html_remnants"] += 1
            
        if re.search(r'\{|\}|\[|\]', desc):
            issues["bracket_remnants"] += 1
            
        lower_desc = desc.lower()
        for kw in suspicious_keywords:
            if kw in lower_desc:
                issues["suspicious_patterns"] += 1
                break
                
        sentences = re.split(r'(?<=[.!?])\s+', desc)
        for s in sentences:
            if s and s[0].islower() and len(s) > 5:
                issues["uncapitalized_sentences"] += 1
                break
                
        if not re.search(r'[.!?\"\'\u2019\u201D]$', desc.strip()):
            issues["missing_punctuation_at_end"] += 1
            
        found_unusual = acceptable_chars_regex.findall(desc)
        for char in found_unusual:
            issues["unusual_characters"][char] += 1

    results = {
        "summary": {
            "multiple_spaces": issues["multiple_spaces"],
            "leading_trailing_spaces": issues["leading_trailing_spaces"],
            "html_remnants": issues["html_remnants"],
            "bracket_remnants": issues["bracket_remnants"],
            "suspicious_patterns": issues["suspicious_patterns"],
            "uncapitalized_sentences": issues["uncapitalized_sentences"],
            "missing_punctuation_at_end": issues["missing_punctuation_at_end"]
        },
        "unusual_characters": [{"char": k, "unicode": f"U+{ord(k):04X}", "count": v} for k, v in issues["unusual_characters"].most_common(50)]
    }
    
    with open(outfile, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)

if __name__ == "__main__":
    validate_dataset("assets/books_data.json", "validation_results.json")
