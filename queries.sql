-- Данный запрос считает количество уникальных покупателей из таблицы customers
SELECT count(DISTINCT customer_id) as customers_count
FROM customers