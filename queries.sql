select count(customer_id) as customers_count from customers;
-- данный запрос вернет суммарное количество клиентов из таблицы customers
select 
	concat(emp.first_name, ' ', emp.last_name) as name,
	count(sales.sales_id) as operations,
	round(sum(pr.price * sales.quantity)) as income
from employees as emp
inner join sales
on sales.sales_person_id = emp.employee_id
inner join products as pr
on pr.product_id = sales.product_id
group by concat(emp.first_name, ' ', emp.last_name)
order by round(sum(pr.price * sales.quantity))  desc
limit 10;
-- данный запрос вернет 10 продавцов продавших товары с наибольшой выручкой
select 
	name,
	round(income/count)
from sales_sum
group by name, (income/count)
having income/count < (sum(income)/sum(count))
order by round(income/count);
--данный запрос вернет продавцов чья средняя выручка по сделке ниже средней по всем продавцам
--отсортированных в прямом порядке
--выборка происходит из первого запроса сохраненного в таблицу
select
	concat(emp.first_name, ' ', emp.last_name),
	to_char(sale_date, 'Day'),
	round(sum(quantity * price))
from employees as emp
inner join sales
on emp.employee_id = sales.sales_person_id
inner join products
on products.product_id = sales.product_id
group by concat(emp.first_name, ' ', emp.last_name), sale_date
order by sale_date, concat(emp.first_name, ' ', emp.last_name);
-- данный запрос вернет суммарную выручку за день каждого продавца
-- отсортированную по порядковым номерам дней недели и имени продавца
select
case
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
end as age_category,
count(*)
from customers
group by age_category
order by age_category;
--вернет количество покупателей разных возрастных категорий
select * from customers;
select 
	concat(to_char(s.sale_date, 'YYYY'), '-', to_char(s.sale_date, 'MM')) as date,
	count(distinct s.customer_id) as total_customers,
	round(sum(s.quantity * p.price), 0) as income
from sales as s
inner join products as p
on s.product_id = p.product_id
group by date
order by date;
--вернет выручку и количество уникальных покупателей по месяцам
with summary as (
select
	concat(cust.first_name, ' ', cust.last_name) as customer,
	first_value(s.sale_date) over (partition by concat(cust.first_name, ' ', cust.last_name) order by sale_date) as sale_date,
	concat(emp.first_name, ' ', emp.last_name) as seller,
	(first_value(price) over (partition by concat(cust.first_name, ' ', cust.last_name) order by concat(cust.first_name, ' ', cust.last_name), sale_date)) as price,
	cust.customer_id
	from customers as cust
	inner join sales as s
	on cust.customer_id = s.customer_id
	inner join employees as emp
	on s.sales_person_id = emp.employee_id
	inner join products as p
	on p.product_id = s.product_id
	order by customer_id
)
select 
	customer,
	sale_date,
	seller
	from summary
	where price = 0
	group by customer, sale_date, seller;
--вернет имена покупателей, чья первая покупка пришлась на акцию, дату первой покупки и продавца отсортированных по айди покупателя