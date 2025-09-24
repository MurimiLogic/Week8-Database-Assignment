-- Library Management System Database (Question 1)


CREATE DATABASE IF NOT EXISTS library_management_system;
USE library_management_system;

-- 1. Members table - stores library member information
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_type ENUM('Student', 'Regular', 'Premium') DEFAULT 'Regular',
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Authors table - stores book author information
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_year YEAR,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Publishers table - stores publisher information
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Books table - stores book information
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    publication_year YEAR,
    edition VARCHAR(20),
    genre VARCHAR(50) NOT NULL,
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    publisher_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL
);

-- 5. Book-Author relationship table (Many-to-Many)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    contribution_type ENUM('Primary', 'Co-author', 'Editor', 'Translator') DEFAULT 'Primary',
    
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- 6. Book copies table - tracks individual physical copies
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    acquisition_date DATE NOT NULL,
    purchase_price DECIMAL(10,2),
    location VARCHAR(50) DEFAULT 'General Collection',
    copy_condition ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'Good',
    status ENUM('Available', 'Checked Out', 'Reserved', 'Under Repair', 'Lost') DEFAULT 'Available',
    barcode VARCHAR(50) UNIQUE,
    
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- 7. Loans table - tracks book borrowing
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    late_fee DECIMAL(8,2) DEFAULT 0.00,
    loan_status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    
    -- Ensure a book copy cannot be loaned twice when not returned
    UNIQUE KEY unique_active_loan (copy_id, loan_status)
);

-- 8. Reservations table - for book reservations
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_status ENUM('Pending', 'Fulfilled', 'Cancelled') DEFAULT 'Pending',
    priority INT DEFAULT 1,
    expiry_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- 9. Fines table - tracks member fines
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    loan_id INT,
    fine_amount DECIMAL(8,2) NOT NULL,
    fine_reason ENUM('Late Return', 'Damage', 'Lost Book') NOT NULL,
    fine_date DATE NOT NULL,
    paid_date DATE,
    fine_status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE SET NULL
);

-- 10. Staff table - library staff information
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_genre ON books(genre);
CREATE INDEX idx_members_name ON members(last_name, first_name);
CREATE INDEX idx_loans_dates ON loans(loan_date, due_date, return_date);
CREATE INDEX idx_loans_member ON loans(member_id, loan_status);
CREATE INDEX idx_copies_status ON book_copies(status, book_id);

-- Insert sample data
INSERT INTO publishers (name, established_year, email) VALUES 
('Penguin Random House', 2013, 'contact@penguinrandomhouse.com'),
('HarperCollins', 1817, 'info@harpercollins.com'),
('Simon & Schuster', 1924, 'support@simonandschuster.com');

INSERT INTO authors (first_name, last_name, birth_year, nationality) VALUES 
('George', 'Orwell', 1903, 'British'),
('J.K.', 'Rowling', 1965, 'British'),
('Stephen', 'King', 1947, 'American');

INSERT INTO books (isbn, title, publication_year, genre, publisher_id) VALUES 
('978-0451524935', '1984', 1949, 'Dystopian Fiction', 1),
('978-0439708180', 'Harry Potter and the Sorcerer''s Stone', 1997, 'Fantasy', 2),
('978-1501142970', 'The Shining', 1977, 'Horror', 3);

INSERT INTO book_authors (book_id, author_id, contribution_type) VALUES 
(1, 1, 'Primary'),
(2, 2, 'Primary'),
(3, 3, 'Primary');

INSERT INTO book_copies (book_id, acquisition_date, status) VALUES 
(1, '2023-01-15', 'Available'),
(1, '2023-01-15', 'Available'),
(2, '2023-02-20', 'Available'),
(3, '2023-03-10', 'Available');

INSERT INTO members (first_name, last_name, email, membership_date) VALUES 
('John', 'Doe', 'john.doe@email.com', '2024-01-10'),
('Jane', 'Smith', 'jane.smith@email.com', '2024-02-15');

-- Create a view for available books
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.genre,
    a.first_name,
    a.last_name,
    COUNT(bc.copy_id) as available_copies
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.status = 'Available'
GROUP BY b.book_id, b.title, b.isbn, b.genre, a.first_name, a.last_name;

-- Create a view for current active loans
CREATE VIEW current_loans AS
SELECT 
    m.first_name,
    m.last_name,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.loan_status = 'Active';
