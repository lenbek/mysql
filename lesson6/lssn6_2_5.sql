-- 2. Создать все необходимые внешние ключи и диаграмму отношений.
ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL,
  ADD CONSTRAINT profiles_ustatus_id_fk
    FOREIGN KEY (user_status_id) REFERENCES user_statuses(id)
      ON DELETE SET NULL,
  ADD CONSTRAINT profiles_country_id_fk
    FOREIGN KEY (country_id) REFERENCES  countrys(id)
      ON DELETE SET NULL
 ;
 
ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_mstatus_id_fk 
    FOREIGN KEY (msg_status_id) REFERENCES message_statuses(id)
 ;

ALTER TABLE friendship  
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_status_id_fk 
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
;  

ALTER TABLE communities_users 
  ADD CONSTRAINT communities_users_comm_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT communities_users_usr_fk 
    FOREIGN KEY (user_id) REFERENCES users(id) 
;     


ALTER TABLE media   
  ADD CONSTRAINT media_user_fk 
    FOREIGN KEY (user_id) REFERENCES users(id), 
  ADD CONSTRAINT media_mtp_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)    
;   

ALTER TABLE likes    
  ADD CONSTRAINT likes_user_fk 
    FOREIGN KEY (user_id) REFERENCES users(id), 
  ADD CONSTRAINT likes_target_tp_fk 
    FOREIGN KEY (target_type_id) REFERENCES target_types(id)    
;   

ALTER TABLE posts      
  ADD CONSTRAINT posts_user_fk 
    FOREIGN KEY (user_id) REFERENCES users(id), 
  ADD CONSTRAINT posts_community_fk 
    FOREIGN KEY (community_id ) REFERENCES communities(id), 
  ADD CONSTRAINT posts_media_fk 
    FOREIGN KEY (media_id) REFERENCES media(id)    
;  



-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
select *
  from (select gender, count(*) as cnt
		  from ( SELECT id,
					   (select p.gender from vk.profiles p where p.user_id = l.user_id) as gender
				  from vk.likes l
			   ) t
		 group by gender ) t 
where cnt = (select max(cnt)
			  from (select gender, count(*) as cnt
					  from ( SELECT id,
								   (select p.gender from vk.profiles p where p.user_id = l.user_id) as gender
							  from vk.likes l
						   ) t
					 group by gender ) t )

 ;


-- 4. Подсчитать количество лайков которые получили 10 самых молодых пользователей.
SELECT user_id,
	   (select count(*)
	   	  from vk.likes l
		 where target_type_id = (select id from vk.target_types where name = 'users')
		   and target_id = p.user_id
	   ) as cnt
  from vk.profiles p
 order by birthday desc limit 10 
  ;
 

-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в
-- использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).
-- пользователь активный - если в течение года у пользователя есть хотя бы одна активность:
-- 	- поставил лайк
--  - создал/отредактировал пост
--  - отправил сообщение 
-- наименьшая активность среди активных пользователей - определяем по ниаменьшему общему количеству: 
--     постевленные лайки (без дублей), созданные/отред.посты, отправленные сообщения 
-- за последний год

 select *
  from  ( 
		 select user_id, count(*) as cnt, 1 as is_active
		   from (
				 select user_id from (SELECT distinct user_id, target_id, target_type_id from vk.likes where created_at > ADDDATE(CURDATE(), INTERVAL -1 YEAR)) l 
				  union ALL 
				 select user_id from vk.posts where updated_at > ADDDATE(CURDATE(), INTERVAL -1 YEAR)
				   union ALL 
				 select from_user_id from vk.messages where created_at > ADDDATE(CURDATE(), INTERVAL -1 YEAR)
		        ) u
		   group by user_id  
		   union ALL 
		  SELECT user_id, 0, 0
		    from profiles p2 
		   where user_id not in (
					   		select user_id from vk.likes where created_at > ADDDATE(CURDATE(), INTERVAL -1 YEAR) 
							  union ALL 
							 select user_id from vk.posts where updated_at > ADDDATE(CURDATE(), INTERVAL -1 YEAR)
							   union ALL 
							 select from_user_id from vk.messages where created_at > ADDDATE(CURDATE(), INTERVAL -1 YEAR))
		   ) g
 order by is_active desc, cnt limit 10
   
 
 