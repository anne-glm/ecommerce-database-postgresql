CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    role_id INT NOT NULL REFERENCES roles(id),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255)
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    parent_id INT REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(id) ON DELETE SET NULL,
    supplier_id INT REFERENCES suppliers(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    product_type VARCHAR(20) NOT NULL CHECK (product_type IN ('physical', 'digital')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE physical_products (
    product_id INT PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    weight_grams INT CHECK (weight_grams >= 0),
    dimensions VARCHAR(50)
);

CREATE TABLE digital_products (
    product_id INT PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    download_url VARCHAR(500) NOT NULL,
    file_size_mb INT CHECK (file_size_mb >= 0)
);

CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    quantity_in_stock INT NOT NULL DEFAULT 0 CHECK (quantity_in_stock >= 0),
    reorder_level INT DEFAULT 10 CHECK (reorder_level >= 0),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    UNIQUE (cart_id, product_id)
);

CREATE TABLE discount_coupons (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent DECIMAL(5, 2) CHECK (discount_percent >= 0 AND discount_percent <= 100),
    max_discount_amount DECIMAL(10, 2) CHECK (max_discount_amount >= 0),
    valid_until TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    coupon_id INT REFERENCES discount_coupons(id) ON DELETE SET NULL,
    order_status VARCHAR(50) NOT NULL DEFAULT 'pending' 
        CHECK (order_status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'failed')),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL,
    transaction_code VARCHAR(255) UNIQUE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_status VARCHAR(50) NOT NULL DEFAULT 'pending' 
        CHECK (payment_status IN ('pending', 'success', 'failed', 'refunded')),
    paid_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE shipping (
    id SERIAL PRIMARY KEY,
    order_id INT UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    shipping_address TEXT NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    shipping_status VARCHAR(50) DEFAULT 'processing' 
        CHECK (shipping_status IN ('processing', 'shipped', 'in_transit', 'delivered', 'failed')),
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_supplier_id ON products(supplier_id);
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);