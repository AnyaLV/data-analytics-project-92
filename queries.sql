-- Задача customers_count
-- Данный запрос считает количество уникальных покупателей из таблицы customers
SELECT count(DISTINCT customer_id) as customers_count
FROM customers

--Задача top_10_total_income
-- В данном запросе произведено объединение трех таблиц с целью определить количество сделок их сумму по каждому продавцу.
-- Далее получившиеся результаты были отсортированы в порядке убывания и выбраны первые 10 продавцов. 
select e.first_name||' '||e.last_name as name,
		count (distinct sales_id) as operations,
		round(sum(p.price* s.quantity),0) as income
from sales s inner join employees e on s.sales_person_id = e.employee_id 
			inner join products p on s.product_id = p.product_id 
group by 1
order by income desc
limit 10

-- Второй вариант решения задачи top_10_total_income
with table1 as (
				select e.first_name||' '||e.last_name as name,
				count (distinct sales_id) as operations,
				round(sum(p.price* s.quantity),0) as income,
				row_number() over(order by sum(p.price* s.quantity) desc) as rn
				from sales s inner join employees e on s.sales_person_id = e.employee_id 
							inner join products p on s.product_id = p.product_id 
				group by 1
				)
select name,operations,income
from table1
where rn <=10

--Задача lowest_average_income
-- В данном запросе произведено объединение трех таблиц для расчета выручки по каждому продавцу. 
-- Далее получившиеся результаты сравнили со средним значением выручки по всем продавцам и оставили только те, которые ниже среднего.
with table1 as (
				select e.first_name||' '||e.last_name as name,
						round(sum(p.price* s.quantity),0) as income
				from sales s inner join employees e on s.sales_person_id = e.employee_id 
							inner join products p on s.product_id = p.product_id 
				group by 1
				)
select name, income
from table1
where income < (select avg(income)from table1)
order by income asc

--Задача day_of_the_week_income
-- В данном запросе произведено объединение трех таблиц для расчета выручки по каждому продавцу в разрезе дня недели.
-- Чтобы корректно отсортировать результат дополнительно добавлена колонка с номером недели. 
select name,week_day,income
from (
		select e.first_name||' '||e.last_name as name,
				to_char(s.sale_date,'day') as week_day,
				extract(ISODOW from s.sale_date) as num_day,
				round(sum(p.price* s.quantity),0) as income
		from sales s inner join employees e on s.sales_person_id = e.employee_id 
					inner join products p on s.product_id = p.product_id 
		group by 1,2,3
		) as table1
order by num_day asc, name asc

