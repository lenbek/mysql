-- 1. Проанализировать, какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.
create index usr_name_idx on users(first_name, last_name); -- для поиска пользователя во фамилии, имени 
create index msg_usr_idx on messages(from_user_id); -- для отображения пользователю его сообщений
create index post_usr_idx on posts(user_id); -- для отображения пользователю его постов
create index post_community_idx on posts(community_id); -- для отображения всех постов сообщества
create index like_trgt_idx on likes(target_type_id, target_id); -- для отображения лайков по объекту; выбор объектов с максимальным кол-вом лайков

 
 
-- 2. Построить запрос, который будет выводить следующие столбцы:
-- имя группы 
-- среднее количество пользователей в группах 
-- самый молодой пользователь в группе 
-- самый старший пользователь в группе 
-- общее количество пользователей в группе 
-- всего пользователей в системе 
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

select t.grp_name, 		-- имя группы 
	   t.avg_usr, 		-- среднее количество пользователей в группах 
	   t.young_usr_id, 	-- самый молодой пользователь в группе 
	   t.old_usr_id, 	-- самый старший пользователь в группе 
	   t.cnt_usr,		-- общее количество пользователей в группе 
	   t.cnt_usr_all, 	-- всего пользователей в системе  
	   round(t.cnt_usr / t.cnt_usr_all * 100,2) -- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100
  from (select t.grp_name, 
			   count(*) as cnt_usr,
			   count(*) over() as cnt_grp, 
			   avg(count(*)) over() as avg_usr,  
			   min(t.young_usr_id) as young_usr_id,  
			   min(t.old_usr_id) as old_usr_id,
			   min(t.cnt_usr_all) as cnt_usr_all
		  from (select c.name grp_name,  
					   FIRST_VALUE(p.user_id) over (partition by c.id order by p.birthday) as young_usr_id,  
					   FIRST_VALUE(p.user_id) over (partition by c.id order by p.birthday desc) as old_usr_id,
					   p.cnt_usr_all
				  from vk.communities c
				 inner join vk.communities_users cu
				 	     on c.id = cu.community_id 
				 	    and curdate() between cu.from_at and cu.till_at 
				 inner join (select p.user_id, p.birthday, count(*) over() as cnt_usr_all from vk.profiles p) p 
				 	     on p.user_id = cu.user_id 
		  	   ) t
		 GROUP by t.grp_name
	   ) t
;
 
 	     
 	     