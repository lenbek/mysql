use  bd_lsn7;

-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
SELECT *
  from users u
 where u.id in (select user_id from orders)
; 

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
select p.id,
	   p.name,
	   p.description,
	   p.price,
	   c.name as catalog_name
  from products p
  left join catalogs c 
         on c.id = p.catalog_id 		 
;

-- 3. Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

select f.id,
	   cf.name as city_from,
	   ct.name as city_to
  from flights f,
  	   cities cf,
  	   cities ct
 where f.col_from = cf.label
   and f.col_to = ct.label
 order by 1
 ;

/*
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id 	SERIAL PRIMARY KEY,
  col_from	VARCHAR(255),
  col_to  	VARCHAR(255)   
);

INSERT INTO flights VALUES
  (NULL, 'moscow', 'omsk' ), 
  (NULL, 'novgorod', 'kazan' ), 
  (NULL, 'irkutsk', 'moscow' ), 
  (NULL, 'omsk', 'irkutsk' ), 
  (NULL, 'moscow', 'kazan' )  
;

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  label VARCHAR(255) ,
  name 	VARCHAR(255) 
) ;

INSERT INTO cities VALUES
  ('moscow', 'Москва'),
  ('irkutsk', 'Иркутск'),
  ('novgorod', 'Новгород'),
  ('kazan', 'Казань'),
  ('omsk', 'Омск')
 ;
*/