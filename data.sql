-- Roles
INSERT INTO roles (role_name) VALUES 
('admin'), 
('customer'), 
('support');

-- Users
INSERT INTO users (role_id, first_name, last_name, email, password_hash) VALUES
(1, 'Ali', 'Ahmadi', 'ali.admin@example.com', 'hash_pwd_admin_123'),
(2, 'Sara', 'Rad', 'sara.customer@example.com', 'hash_pwd_sara_456'),
(2, 'Reza', 'Mohammadi', 'reza.m@example.com', 'hash_pwd_reza_789');

-- Suppliers
INSERT INTO suppliers (company_name, contact_name, phone, email) VALUES
('TechNova Ltd', 'Arash Karimi', '+989121112233', 'sales@technova.com'),
('Persian Books Co', 'Maryam Tehrani', '+989123334455', 'info@persianbooks.ir');

-- Categories
INSERT INTO categories (parent_id, name, slug) VALUES
(NULL, 'Electronics', 'electronics'),
(1, 'Laptops & Computers', 'laptops-computers'),
(NULL, 'Digital Content', 'digital-content'),
(3, 'E-Books & Courses', 'ebooks-courses');

-- Products
INSERT INTO products (category_id, supplier_id, name, sku, description, price, product_type) VALUES
(2, 1, 'Pro Gaming Laptop 16-inch', 'SKU-LAP-001', 'High performance laptop with 32GB RAM', 1850.00, 'physical'),
(2, 1, 'Wireless Ergonomic Mouse', 'SKU-MOU-002', 'Bluetooth rechargeable mouse', 45.00, 'physical'),
(4, 2, 'PostgreSQL Mastery Video Course', 'SKU-CRS-101', 'Comprehensive database design & SQL course', 29.99, 'digital'),
(4, 2, 'Advanced Algorithms E-Book', 'SKU-BOK-102', 'PDF handbook covering advanced graph algorithms', 15.00, 'digital');

-- Physical Products
INSERT INTO physical_products (product_id, weight_grams, dimensions) VALUES
(1, 2300, '35x25x2 cm'),
(2, 110, '12x7x4 cm');

-- Digital Products
INSERT INTO digital_products (product_id, download_url, file_size_mb) VALUES
(3, 'https://cdn.example.com/courses/pg-mastery.zip', 4500),
(4, 'https://cdn.example.com/books/algo-adv.pdf', 35);

-- Product Images
INSERT INTO product_images (product_id, image_url, is_primary) VALUES
(1, 'https://img.example.com/laptop-main.jpg', TRUE),
(1, 'https://img.example.com/laptop-side.jpg', FALSE),
(2, 'https://img.example.com/mouse-main.jpg', TRUE),
(3, 'https://img.example.com/course-cover.jpg', TRUE);

-- Inventory
INSERT INTO inventory (product_id, quantity_in_stock, reorder_level) VALUES
(1, 50, 5),
(2, 100, 15),
(3, 99999, 0),
(4, 99999, 0);

-- Discount Coupons
INSERT INTO discount_coupons (code, discount_percent, max_discount_amount, valid_until, is_active) VALUES
('WELCOME10', 10.00, 50.00, NOW() + INTERVAL '30 days', TRUE),
('NOROOZ25', 25.00, 100.00, NOW() + INTERVAL '60 days', TRUE);

-- Carts & Cart Items
INSERT INTO carts (user_id) VALUES (2);
INSERT INTO cart_items (cart_id, product_id, quantity) VALUES
(1, 2, 2);

-- Orders & Order Items
INSERT INTO orders (user_id, coupon_id, order_status, total_amount) VALUES
(2, 1, 'pending', 1805.00); 

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1850.00);

-- Payments
INSERT INTO payments (order_id, payment_method, transaction_code, amount, payment_status) VALUES
(1, 'credit_card', 'TXN-2026-998811', 1805.00, 'pending');

-- Shipping
INSERT INTO shipping (order_id, shipping_address, tracking_number, shipping_status) VALUES
(1, 'Tehran, Valiasr Ave, No. 124, Apt 5', 'TRK-IR-778899', 'processing');

-- Reviews
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
(2, 1, 5, 'Exceptional build quality and super fast response!'),
(3, 3, 5, 'Great explanation of database indexing and transactions.');