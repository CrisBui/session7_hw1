CREATE TABLE book (
                      book_id SERIAL PRIMARY KEY,
                      title VARCHAR(255),
                      author VARCHAR(100),
                      genre VARCHAR(50),
                      price DECIMAL(10,2),
                      description TEXT,
                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO book (title, author, genre, price, description)
SELECT
    -- 1. Sinh tiêu đề sách động theo số vòng lặp
    'Book Title ' || gs AS title,

    -- 2. Ngẫu nhiên 1 trong 10 tác giả nổi tiếng
    (ARRAY[
        'Nguyễn Nhật Ánh', 'Nam Cao', 'Tô Hoài', 'Xuân Quỳnh',
        'Haruki Murakami', 'Dale Carnegie', 'J.K. Rowling',
        'Stephen King', 'Agatha Christie', 'Ernest Hemingway'
        ])[floor(random() * 10 + 1)] AS author,

    -- 3. Ngẫu nhiên 1 trong 10 thể loại sách phổ biến
    (ARRAY[
        'Science', 'History', 'Technology', 'Novel', 'Education',
        'Business', 'Psychology', 'Biography', 'Comic', 'Fantasy'
        ])[floor(random() * 10 + 1)] AS genre,

    -- 4. Ngẫu nhiên giá sách từ 30.000 đến 500.000 VNĐ
    ROUND((random() * 470000 + 30000)::NUMERIC, 2) AS price,

    -- 5. Sinh nội dung mô tả tương ứng cho từng cuốn sách
    'Description details and reviews for book number ' || gs AS description
FROM generate_series(1, 500000) AS gs;


-- 1
-- a
EXPLAIN ANALYSE SELECT * FROM book WHERE author LIKE '%Rowlings%' ;

-- Bật extension hỗ trợ chẻ chuỗi thành cụm 3 ký tự
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Tạo GIN index đúng cú pháp kèm toán tử hỗ trợ
CREATE INDEX idx_book_author_gin ON book USING GIN (author, gin_trgm_ops);

-- b
EXPLAIN ANALYZE SELECT * FROM book WHERE genre = 'Fantasy';

CREATE INDEX idx_book_genre ON book(genre);

-- 3

EXPLAIN ANALYZE SELECT * FROM book WHERE description = 'Description details and reviews for book number';
CREATE INDEX idx_book_description ON book USING gin(description, gin_trgm_ops);

-- 4
EXPLAIN ANALYZE SELECT * FROM book WHERE genre = 'Business';
CLUSTER book USING idx_book_genre;


