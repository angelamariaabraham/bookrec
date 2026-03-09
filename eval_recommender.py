import json
import math
from collections import Counter
import random

def get_tf_idf(data):
    # 1. Calculate Term Frequency and Document Frequency
    doc_frequency = Counter()
    term_frequencies = []
    
    for book in data:
        text = book.get('normalized_description', '').lower()
        words = [w for w in text.split() if len(w) > 2] # simplistic word split
        
        tf = Counter(words)
        term_frequencies.append(tf)
        
        for word in set(words):
            doc_frequency[word] += 1
            
    n = len(data)
    tf_idf_matrix = []
    
    # 2. Calculate TF-IDF
    for i in range(n):
        weights = {}
        for word, count in term_frequencies[i].items():
            tf = float(count)
            idf = math.log(n / max(1, doc_frequency[word]))
            weights[word] = tf * idf
        tf_idf_matrix.append(weights)
        
    return tf_idf_matrix

def cosine_similarity(v1, v2):
    dot_product = 0.0
    mag1 = 0.0
    mag2 = 0.0
    
    all_words = set(v1.keys()).union(set(v2.keys()))
    
    for word in all_words:
        val1 = v1.get(word, 0.0)
        val2 = v2.get(word, 0.0)
        dot_product += val1 * val2
        mag1 += val1 * val1
        mag2 += val2 * val2
        
    if mag1 == 0 or mag2 == 0: return 0.0
    return dot_product / (math.sqrt(mag1) * math.sqrt(mag2))

def get_recommendations(target_idx, matrix, k=6):
    target_vector = matrix[target_idx]
    scores = []
    
    for i, vector in enumerate(matrix):
        if i != target_idx:
            scores.append((i, cosine_similarity(target_vector, vector)))
            
    scores.sort(key=lambda x: x[1], reverse=True)
    return [x[0] for x in scores[:k]]

def evaluate_accuracy(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    print(f"Loaded {len(data)} books. Computing TF-IDF...")
    matrix = get_tf_idf(data)
    
    print("Evaluating recommendation accuracy based on Genre Overlap...")
    
    total_relevant = 0
    total_recommended = 0
    
    # Sample 100 random books to act as our "test set" to save time
    random.seed(42)
    test_indices = random.sample(range(len(data)), min(100, len(data)))
    
    for idx in test_indices:
        target_book = data[idx]
        target_genres_str = target_book.get('genres', '[]')
        try:
            target_genres = set(eval(target_genres_str))
        except:
            target_genres = set()
            
        if not target_genres:
            continue
            
        recs = get_recommendations(idx, matrix, k=5)
        
        for rec_idx in recs:
            rec_book = data[rec_idx]
            rec_genres_str = rec_book.get('genres', '[]')
            try:
                rec_genres = set(eval(rec_genres_str))
            except:
                rec_genres = set()
                
            # If they share at least one genre, consider it "relevant" (a hit)
            if len(target_genres.intersection(rec_genres)) > 0:
                total_relevant += 1
            total_recommended += 1
            
    if total_recommended == 0:
        print("Error: Could not evaluate.")
        return
        
    precision = (total_relevant / total_recommended) * 100
    print(f"\n--- Model Evaluation Results ---")
    print(f"Metric: Precision@5 (At least 1 overlapping genre)")
    print(f"Accuracy: {precision:.2f}%")
    print(f"Interpretation: Out of the top 5 requested recommendations, {precision:.2f}% of them share a genre with the source book.")
    
if __name__ == "__main__":
    evaluate_accuracy("assets/books_data.json")
