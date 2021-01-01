-- =============================================================================================================================
-- Практическое задание теме «Агрегация данных»
-- 1. Подсчитайте средний возраст пользователей в таблице users.
-- =============================================================================================================================
select avg( year(CURRENT_DATE()) - year(u.birthday_at) 
	   		- (date_format(CURRENT_DATE(), '%m%d') < date_format(u.birthday_at, '%m%d'))) as avg_age
  from users u 
; 
 
-- =============================================================================================================================
-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
--    Следует учесть, что необходимы дни недели текущего года, а не года рождения.
-- =============================================================================================================================
select c.daynm, COALESCE(d.cnt,0) as cnt
  from (
  		  with recursive w_clnd(n) as 
  		  ( select 0 as n
  		  	 union all
  		  	select n+1 as n 
  		  	  from w_clnd 
  		  	 where n < 6
  		  )
  		  select dayname(DATE_ADD( CURRENT_DATE(), INTERVAL n day)) daynm,
  		  		 WEEKDAY(DATE_ADD( CURRENT_DATE(), INTERVAL n day)) rn
  		    from w_clnd
  	   ) c
  	   left join
  	   (
			select dayname(DATE_ADD( u.birthday_at , INTERVAL year(CURRENT_DATE()) - year(u.birthday_at) year)) daynm,
				   count(*) as cnt
			  from users u 
			 group by daynm
	   ) d
	   on c.daynm = d.daynm
 order by c.rn
; 
  
-- =============================================================================================================================
-- 3. Подсчитайте произведение чисел в столбце таблицы.
-- =============================================================================================================================
with RECURSIVE 
  w_tst as  (
	select cast(coalesce(p,0) as decimal(65,30)) as p, 
		   ROW_NUMBER () over () as rn, 
		   count(*) over() as cnt, 
		   -- 
		   abs(coalesce(p,0))   as p_exp,
		   case when coalesce(p,0) = 0 then 0 else 1 end as zero,
		   case when p < 0 then 1 else 0 end  as sign 
	  from (
			select 71.0 as p union all
			select 0.6 as p union all
			select 0.3 as p union all
			select -0.4 as p union all
			select 0.5 as p ) t
  ),
   w_op ( p, rn, cnt) as 
  ( select p, rn, cnt
      from w_tst
     where rn = 1
  	 union all
  	select o.p * t.p as p, t.rn, t.cnt
  	  from w_tst t
  	  	   inner join w_op o 
  	  	   	  on t.rn = o.rn + 1  
  )      
 select 'EXP',  EXP(sum(LOG(p_exp))) * min(zero) * (case when sum(sign)%2 = 0 then 1 else -1 end) as pr
   from w_tst 
  union all
 select 'with', p
   from w_op
  where rn = cnt
 ;
 
  