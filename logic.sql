CREATE OR REPLACE FUNCTION fn_process_order_inventory()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
    current_stock INT;
BEGIN
    IF NEW.payment_status = 'success' AND (OLD.payment_status IS DISTINCT FROM 'success') THEN
        
        UPDATE orders 
        SET order_status = 'paid', updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.order_id;

        FOR item IN 
            SELECT product_id, quantity 
            FROM order_items 
            WHERE order_id = NEW.order_id
        LOOP
            SELECT quantity_in_stock INTO current_stock
            FROM inventory
            WHERE product_id = item.product_id
            FOR UPDATE;

            IF current_stock < item.quantity THEN
                RAISE EXCEPTION 'Insufficient stock for product ID %: available %, requested %',
                    item.product_id, current_stock, item.quantity;
            END IF;

            UPDATE inventory
            SET quantity_in_stock = quantity_in_stock - item.quantity,
                last_updated = CURRENT_TIMESTAMP
            WHERE product_id = item.product_id;
        END LOOP;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_after_payment_success ON payments;

CREATE TRIGGER trg_after_payment_success
AFTER UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION fn_process_order_inventory();

CREATE OR REPLACE PROCEDURE sp_complete_payment(p_order_id INT, p_transaction_code VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE payments
    SET payment_status = 'success',
        transaction_code = p_transaction_code,
        paid_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;

    RAISE NOTICE 'Order % payment completed and inventory updated.', p_order_id;
END;
$$;