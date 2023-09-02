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