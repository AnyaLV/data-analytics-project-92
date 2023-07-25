-- Задача customers_count
-- Данный запрос считает количество уникальных покупателей из таблицы customers
SELECT count(DISTINCT customer_id) as customers_count
FROM customers

--Задача top_10_total_income
-- В данном запросе произведено объединение трех таблиц с целью определить количество сделок их сумму по каждому продавцу.
-- Далее получившиеся результаты были отсортированы в порядке убывания и выбраны первые 10 продавцов. 
select e.first_name||' '||e.last_name as name,
		count (distinct sales_id) as operations,
		round(floor(sum(p.price* s.quantity)),0) as income
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
						round(avg(p.price* s.quantity),0) as average_income,
						round(sum(p.price* s.quantity),0) as income
				from sales s left join employees e on s.sales_person_id = e.employee_id 
							left join products p on s.product_id = p.product_id 
				group by 1
				)
select name, average_income
from table1
where average_income < (select avg(average_income)from table1)
order by average_income asc

--Задача day_of_the_week_income
-- В данном запросе произведено объединение трех таблиц для расчета выручки по каждому продавцу в разрезе дня недели.
-- Чтобы корректно отсортировать результат дополнительно добавлена колонка с номером недели. 
select name,weekday,income
from (
		select e.first_name||' '||e.last_name as name,
				to_char(s.sale_date,'day') as weekday,
				extract(ISODOW from s.sale_date) as num_day,
				round(sum(p.price* s.quantity),0) as income
		from sales s inner join employees e on s.sales_person_id = e.employee_id 
					inner join products p on s.product_id = p.product_id 
		group by 1,2,3
		) as table1
order by num_day asc, name asc

--Задача age_groups
--В данном запросе с помощью case when был присвоен сегмент по возрасту и посчитано количество уникальных клиентов в каждом сегменте
select case when age >=16 and age <=25 then '16-25'
			when age >=26 and age <=40 then '26-40'
			else '40+'
			end as age_category,
			count(distinct customer_id)
from customers 
group by 1
order by age_category

--Задача customers_by_month
--В данном запросе произведение двух таблиц, для того, чтобы посчитать уникальное количество клиентов и сумма выручки, которую принес каждый клиент в разрезе месяца и года
select to_char(s.sale_date,'YYYY-MM') as date , count(distinct customer_id) AS total_customers, round(floor(SUM(s.quantity*p.price)),0) as income
from sales s JOIN products p ON s.product_id=p.product_id
group by 1
order by date asc

--Задача special_offer
--Для решения данной задачи использовались cte, в таблице table_1 произведено объединение данных имени и фамилии клиента и продавца, 
--далее посчитана сумма выручки с каждой покупки и присвоен ранг каждой покупки в разрезе клиента. Так мы сможем определить первую покупку клиента.
--Для получения результатов согласно условиям задачи отфильтровали значения с нулевой выручкой и номером покупки - 1
with table_1 as (select c.first_name||' '||c.last_name as customer, 
				s.customer_id, 
				e.first_name||' '||e.last_name as seller, 
				s.sales_id, 
				s.sale_date, 
				s.quantity*p.price as amount, 
				row_number () over(partition by s.customer_id order by sale_date) as rn
from sales s JOIN products p ON s.product_id=p.product_id
			join customers c on s.customer_id=c.customer_id
			join employees e on s.sales_person_id=e.employee_id)
select customer, sale_date, seller
from table_1
where rn=1 and amount=0
order by customer_id asc


