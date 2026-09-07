CREATE OR REPLACE VIEW v_customer_lifetime_value AS
SELECT 
    u.id AS user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    COUNT(o.id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
    COALESCE(AVG(o.total_amount), 0.00) AS average_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id AND o.order_status = 'paid'
GROUP BY u.id, u.first_name, u.last_name;


WITH monthly_product_sales AS (
    SELECT 
        p.id AS product_id,
        p.name AS product_name,
        c.name AS category_name,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM products p
    JOIN categories c ON p.category_id = c.id
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.order_status = 'paid'
    GROUP BY p.id, p.name, c.name
)
SELECT 
    product_id,
    product_name,
    category_name,
    total_revenue,
    DENSE_RANK() OVER (PARTITION BY category_name ORDER BY total_revenue DESC) AS category_rank
FROM monthly_product_sales;


WITH RECURSIVE category_tree AS (
    SELECT 
        id, 
        name, 
        parent_id, 
        1 AS level,
        CAST(name AS VARCHAR(255)) AS path
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.id, 
        c.name, 
        c.parent_id, 
        ct.level + 1,
        CAST(ct.path || ' -> ' || c.name AS VARCHAR(255))
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT id, name, level, path FROM category_tree;


SELECT 
    p.id,
    p.name,
    p.price,
    i.quantity_in_stock,
    i.reorder_level,
    COALESCE(ROUND(AVG(r.rating), 2), 0.00) AS avg_rating,
    COUNT(r.id) AS total_reviews
FROM products p
LEFT JOIN inventory i ON p.id = i.product_id
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.price, i.quantity_in_stock, i.reorder_level;