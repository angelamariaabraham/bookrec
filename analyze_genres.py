import json

def analyze_genres():
    with open('c:/Angela/bookrec/assets/books_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    fantasy_count = 0
    scifi_count = 0
    both_count = 0
    
    only_fantasy = []
    only_scifi = []
    
    for book in data:
        genres = book.get('genres', '').lower()
        has_fantasy = 'fantasy' in genres
        has_scifi = 'science fiction' in genres
        
        if has_fantasy and has_scifi:
            both_count += 1
        elif has_fantasy:
            fantasy_count += 1
            if len(only_fantasy) < 5:
                only_fantasy.append(book['title'])
        elif has_scifi:
            scifi_count += 1
            if len(only_scifi) < 5:
                only_scifi.append(book['title'])
                
    results = []
    results.append(f"Total books analyzed: {len(data)}")
    results.append(f"Books with both Fantasy and Sci-Fi: {both_count}")
    results.append(f"Books with only Fantasy: {fantasy_count}")
    results.append(f"Books with only Science Fiction: {scifi_count}")
    results.append(f"\nOnly Fantasy Examples: {only_fantasy}")
    results.append(f"Only Sci-Fi Examples: {only_scifi}")
    
    with open('c:/Angela/bookrec/genre_results.txt', 'w', encoding='utf-8') as res_f:
        res_f.write('\n'.join(results))
    print("Analysis complete. Results saved to genre_results.txt")

if __name__ == "__main__":
    analyze_genres()
