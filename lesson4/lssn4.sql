-- ================================================================
-- 1. Повторить все действия по доработке БД vk.
-- 2. Заполнить новые таблицы.
-- 3. Повторить все действия CRUD.
-- ================================================================
use vk;
-- -------------------------------
-- users
-- ------------------------------- 
SELECT * FROM users; 

UPDATE users SET updated_at = NOW() WHERE updated_at < created_at;                  

-- -------------------------------
-- profiles
-- ------------------------------- 
DESC profiles;
 
select DISTINCT gender FROM profiles;
 
-- photo_id
select min(id), max(id) from media;
select min(photo_id), max(photo_id) from profiles; 
UPDATE profiles SET photo_id = FLOOR(1 + RAND() * 100) where photo_id > 100;

-- status
-- Таблица статусов пользователей
CREATE TABLE user_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  name VARCHAR(100) NOT NULL COMMENT "Название статуса (уникально)",
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник статусов пользователей";  
INSERT INTO user_statuses (name) VALUES ('single'),('married');
 

UPDATE profiles SET status = NULL;
ALTER TABLE profiles RENAME COLUMN status TO user_status_id;
ALTER TABLE profiles MODIFY COLUMN user_status_id INT UNSIGNED;

UPDATE profiles SET user_status_id = FLOOR(1 + RAND() * 3);
update profiles SET user_status_id = null where user_status_id = 3;

SELECT distinct user_status_id from profiles p ;
 
-- country
CREATE TABLE countrys (
  id  		 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name 		 VARCHAR(150) NOT NULL UNIQUE COMMENT "Название страны",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Страна";
INSERT into countrys (name)
select distinct country
  from profiles ;

ALTER table profiles add column country_id int UNSIGNED comment "Страна проживания" after country ;

UPDATE profiles p
   set country_id = (select id from countrys c where c.name = p.country);
ALTER table profiles drop column country;

SELECT * FROM profiles;

-- -------------------------------
-- messages
-- -------------------------------
-- user_id
select min(from_user_id), max(from_user_id), min(to_user_id), max(to_user_id)  
  from messages;

 SELECT *
   from messages
  where from_user_id is NULL 
     or to_user_id is null
     or from_user_id = to_user_id
 ;

UPDATE messages 
   SET from_user_id = to_user_id +1
 where from_user_id = to_user_id;

-- is_important
select distinct is_important from messages;

-- is_delivered
CREATE TABLE message_statuses (
  id  		 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 					COMMENT "Идентификатор строки",
  name 		 VARCHAR(150) NOT NULL UNIQUE 										COMMENT "Название статуса",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP 								COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT "Время обновления строки"  
) COMMENT "Статус доставки сообщения";
insert into message_statuses (name) values ('deleted'),('send'),('delivered'),('read');

ALTER TABLE messages RENAME COLUMN is_delivered TO msg_status_id;
ALTER TABLE messages MODIFY COLUMN msg_status_id INT UNSIGNED COMMENT "Статус доставки сообщения";

UPDATE messages set msg_status_id = FLOOR(1 + RAND() * 4);

UPDATE messages SET updated_at = NOW() WHERE updated_at < created_at;                  
 
select * from messages;
desc messages;
-- -------------------------------
-- friendship_statuses
-- -------------------------------
TRUNCATE friendship_statuses; 
INSERT INTO friendship_statuses (name) VALUES  ('Requested'), ('Confirmed'), ('Rejected');

-- -------------------------------
-- friendship
-- -------------------------------
-- user_id
select min(user_id), max(user_id), min(friend_id), max(friend_id)  
  from friendship;

 SELECT *
   from friendship
  where user_id is NULL 
     or friend_id is null
     or user_id = friend_id
 ;

UPDATE friendship 
   SET user_id = FLOOR(1 + RAND() * 200),
       friend_id = FLOOR(1 + RAND() * 200);
 
-- status_id
SELECT distinct status_id from friendship;
UPDATE friendship SET status_id = FLOOR(1 + RAND() * 3) where status_id = 4;

-- requested_at 
ALTER table friendship
  add column from_at DATETIME DEFAULT NOW() COMMENT "Время отправления приглашения дружить" after requested_at,
  add column till_at DATETIME DEFAULT '9999-12-31 23:59:59' COMMENT "Время окончания дружбы" after from_at  
;
alter table friendship drop primary key;
alter table friendship add primary key (user_id, friend_id, from_at) ; 
alter table friendship drop requested_at;

UPDATE friendship set from_at = created_at ;
UPDATE friendship set till_at = updated_at where status_id =3;
   
UPDATE friendship set confirmed_at = ADDDATE(from_at, INTERVAL 1 day) where confirmed_at < from_at;

select *
  from friendship
 where confirmed_at > till_at
 ;

select user_id, friend_id
  from friendship
 group by user_id, friend_id 
 having count(*)>1
 ;

select * from friendship;
desc friendship ;
-- -------------------------------
-- communities
-- -------------------------------
SELECT * FROM communities; 
DELETE FROM communities WHERE id > 20;
-- -------------------------------
-- communities_users
-- ------------------------------- 
UPDATE communities_users SET community_id = FLOOR(1 + RAND() * 20);
 
select community_id, user_id 
  from communities_users
 group by community_id, user_id 
 having count(*)>1
 ;

ALTER table communities_users
  add column from_at DATETIME DEFAULT NOW() COMMENT "Время присоединения пользователя к группе",
  add column till_at DATETIME DEFAULT '9999-12-31 23:59:59' COMMENT "Время выхода пользователя из группы"
;
alter table communities_users drop primary key;
alter table communities_users add primary key (community_id, user_id, from_at); 

UPDATE communities_users set from_at = created_at ;  
alter table communities_users drop created_at;
 
  
SELECT * FROM communities_users;
desc communities_users;
-- -------------------------------
-- media_types
-- -------------------------------
truncate media_types;
 
INSERT INTO media_types (name) VALUES ('photo'), ('video'), ('audio');
-- -------------------------------
-- media
-- ------------------------------- 

-- user_id
SELECT min(user_id), max(user_id) from media; 
UPDATE media SET user_id = FLOOR(1 + RAND() * 200);

-- filename 
CREATE TEMPORARY TABLE extensions (name VARCHAR(10)); 
INSERT INTO extensions VALUES ('jpeg'), ('avi'), ('mpeg'), ('png'); 
SELECT * FROM extensions;
 
UPDATE media 
   SET filename = CONCAT(
				  'http://dropbox.net/vk/',
				  filename,
				  (SELECT last_name FROM users ORDER BY RAND() LIMIT 1),
				  '.',
				  (SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
				);


-- media_type_id
UPDATE media SET media_type_id = FLOOR(1 + RAND() * 3);
 
-- size
UPDATE media SET size = FLOOR(10000 + (RAND() * 1000000)) WHERE size < 1000;

-- metadata
UPDATE media 
  SET metadata = CONCAT('{"owner":"',  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id), '"}');  
 
ALTER TABLE media MODIFY COLUMN metadata JSON;


SELECT * FROM media;



-- ================================================================
-- 4. Подобрать сервис-образец для курсовой работы.
-- ================================================================
-- БД: настроечные таблицы для планировщика запука потоков задач:
--  потоки, задачи, связь потоков и задач, параметры потоков, логирование выполнения
