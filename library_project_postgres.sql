-- Library Management System - PostgreSQL Project Script

-- Drop existing tables if needed
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS book_authors CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS members CASCADE;

-- 1. Members
CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE NOT NULL,
    city VARCHAR(50)
);

-- 2. Books
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    year_published INT CHECK (year_published > 0),
    price NUMERIC(8,2)
);

-- 3. Authors
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

-- 4. BookAuthors (bridge for many-to-many)
CREATE TABLE book_authors (
    book_id INT REFERENCES books(book_id) ON DELETE CASCADE,
    author_id INT REFERENCES authors(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

-- 5. Loans
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
    book_id INT REFERENCES books(book_id) ON DELETE CASCADE,
    borrow_date DATE NOT NULL,
    due_date DATE,
    return_date DATE,
    CHECK (due_date IS NULL OR due_date >= borrow_date)
);

-- 6. Notifications (trigger target)
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    loan_id INT REFERENCES loans(loan_id) ON DELETE CASCADE,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO members (name, email, join_date, city) VALUES
('Pushpa Rao','pushpa@example.com','2024-08-12','Bangalore'),
('Anil Kumar','anil@example.com','2022-04-22','Mumbai'),
('Raj Kumar','raj@example.com','2021-01-02','Chennai');

INSERT INTO books (title, year_published, price) VALUES
('Book One',2018,250),
('Book Two',2020,400),
('Book Three',2016,150);

INSERT INTO authors (full_name) VALUES
('Author A'),
('Author B'),
('Author C');

INSERT INTO book_authors (book_id,author_id) VALUES
(1,1),(2,2),(3,3);

INSERT INTO loans (member_id, book_id, borrow_date, return_date)
VALUES (1,2,'2025-01-10','2025-01-20'),
       (2,1,'2025-02-01','2025-02-10'),
       (3,3,'2025-02-15',NULL);

-- Trigger: auto due_date (14 days after borrow)
CREATE OR REPLACE FUNCTION set_due_date()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.due_date IS NULL THEN
    NEW.due_date := NEW.borrow_date + INTERVAL '14 days';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_due_date
BEFORE INSERT ON loans
FOR EACH ROW EXECUTE FUNCTION set_due_date();

-- Trigger: overdue notification
CREATE OR REPLACE FUNCTION notify_overdue()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.return_date IS NULL AND NEW.due_date < CURRENT_DATE THEN
    INSERT INTO notifications (loan_id, message)
    VALUES (NEW.loan_id, 'Loan is overdue!');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notify_overdue
AFTER INSERT OR UPDATE ON loans
FOR EACH ROW EXECUTE FUNCTION notify_overdue();

-- Views
CREATE OR REPLACE VIEW v_borrowed_book_details AS
SELECT m.name AS member_name, b.title AS book_title, l.borrow_date, l.return_date
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN books b ON l.book_id = b.book_id;

CREATE OR REPLACE VIEW v_current_loans AS
SELECT l.loan_id, m.name, b.title, l.borrow_date, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL;

CREATE OR REPLACE VIEW v_overdue_loans AS
SELECT l.loan_id, m.name, b.title, l.borrow_date, l.due_date,
       CURRENT_DATE - l.due_date AS days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE;
