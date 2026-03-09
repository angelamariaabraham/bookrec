import json

def main():
    file_path = 'c:/Angela/bookrec/assets/books_data.json'
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    original_count = len(data)
    filtered_data = []

    for item in data:
        # Check if description exists and is not null/empty
        desc = item.get('description')
        if desc is not None and str(desc).strip() != '':
            filtered_data.append(item)

    print(f"Original books: {original_count}")
    print(f"Filtered books: {len(filtered_data)}")
    print(f"Removed {original_count - len(filtered_data)} books with missing descriptions.")

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(filtered_data, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    main()
