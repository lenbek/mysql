--======================================================================================================================================
-- 1. Проанализировать структуру БД vk, которую мы создали на занятии, и внести предложения по усовершенствованию (если такие идеи есть). 
--======================================================================================================================================
-- profiles: status, city (может и не надо), country сделать ссылками на справочники; добавить ограничение на поле
-- messages: поле is_delivered заменить на status_id - ссылка на справочник (удалено, отправлено, доставлено, прочитано)
-- friendship: requested_at удалить; добавить период дружбы from_at, till_at; считаем from_dt = requested_at; 
-- communities_users: добавить период вхождения пользователя в группу from_at, till_at
-- FK на таблицы; историзация (в отдельных таблицах) на тех сущностях, где надо 

-- Таблица профилей
CREATE TABLE profiles (
  user_id 	 INT UNSIGNED NOT NULL PRIMARY KEY 								COMMENT "Ссылка на пользователя", 
  gender 	 CHAR(1) NOT NULL CHECK (gender IN ('M','F'))					COMMENT "Пол",
  birthday 	 DATE 															COMMENT "Дата рождения",
  photo_id 	 INT UNSIGNED 													COMMENT "Ссылка на основную фотографию пользователя",
  status_id  INT UNSIGNED 													COMMENT "Текущий статус",
  city_id 	 INT UNSIGNED 													COMMENT "Город проживания",
  country_id INT UNSIGNED													COMMENT "Страна проживания",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP 							COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Профили"; 

CREATE TABLE profile_statuses (
  id  		 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name 		 VARCHAR(150) NOT NULL UNIQUE COMMENT "Название статуса",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Статус пользователя";

CREATE TABLE countrys (
  id  		 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name 		 VARCHAR(150) NOT NULL UNIQUE COMMENT "Название страны",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Страна";

CREATE TABLE cities (
  id  		 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 				COMMENT "Идентификатор строки",
  name 		 VARCHAR(150) NOT NULL UNIQUE 					  				COMMENT "Название города",
  country_id INT UNSIGNED						  			  				COMMENT "Страна",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP 			  				COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Города";


-- Таблица сообщений
CREATE TABLE messages (
  id 			INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 				COMMENT "Идентификатор строки", 
  from_user_id 	INT UNSIGNED NOT NULL 											COMMENT "Ссылка на отправителя сообщения",
  to_user_id 	INT UNSIGNED NOT NULL 											COMMENT "Ссылка на получателя сообщения",
  body TEXT 	NOT NULL 														COMMENT "Текст сообщения",
  is_important 	BOOLEAN 														COMMENT "Признак важности",
  status_id  	INT UNSIGNED 												   	COMMENT "Текущий статус",
  created_at 	DATETIME DEFAULT NOW() 										   	COMMENT "Время создания строки",
  updated_at 	DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT "Время обновления строки"
) COMMENT "Сообщения";

CREATE TABLE message_statuses (
  id  		 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 					COMMENT "Идентификатор строки",
  name 		 VARCHAR(150) NOT NULL UNIQUE 										COMMENT "Название статуса",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP 								COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT "Время обновления строки"  
) COMMENT "Статус пользователя";

-- Таблица дружбы
CREATE TABLE friendship (
  user_id 		INT UNSIGNED NOT NULL 											COMMENT "Ссылка на инициатора дружеских отношений",
  friend_id 	INT UNSIGNED NOT NULL 											COMMENT "Ссылка на получателя приглашения дружить",
  status_id 	INT UNSIGNED NOT NULL 											COMMENT "Ссылка на статус (текущее состояние) отношений",
  from_at 		DATETIME DEFAULT NOW() 											COMMENT "Время отправления приглашения дружить",
  till_at 		DATETIME DEFAULT '9999-12-31 23:59:59' 							COMMENT "Время окончания дружбы",
  confirmed_at 	DATETIME 														COMMENT "Время подтверждения приглашения",
  created_at 	DATETIME DEFAULT CURRENT_TIMESTAMP 								COMMENT "Время создания строки",  
  updated_at 	DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT "Время обновления строки",  
  PRIMARY KEY (user_id, friend_id, from_at) 									COMMENT "Составной первичный ключ"
) COMMENT "Таблица дружбы";

-- Таблица связи пользователей и групп
CREATE TABLE communities_users (
  community_id  INT UNSIGNED NOT NULL 					COMMENT "Ссылка на группу",
  user_id 		INT UNSIGNED NOT NULL 					COMMENT "Ссылка на пользователя",
  from_at 		DATETIME DEFAULT NOW() 					COMMENT "Время присоединения пользователя к группе",
  till_at 		DATETIME DEFAULT '9999-12-31 23:59:59' 	COMMENT "Время выхода пользователя из группы",
  PRIMARY KEY (community_id, user_id, from_at) 			COMMENT "Составной первичный ключ"
) COMMENT "Участники групп, связь между пользователями и группами";


--======================================================================================================================================
-- 2. Добавить необходимую таблицу/таблицы для того, чтобы можно было использовать лайки для медиафайлов, постов и пользователей.
--======================================================================================================================================
CREATE TABLE entity (
	id 			INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 				COMMENT "Идентификатор строки",
    name 		VARCHAR(255) NOT NULL UNIQUE 									COMMENT "Название сущности",
    created_at 	DATETIME DEFAULT CURRENT_TIMESTAMP 								COMMENT "Время создания строки",  
    updated_at 	DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 	COMMENT "Время обновления строки"
) COMMENT "Сущности";

CREATE TABLE entity_like (
  entity_id		INT UNSIGNED NOT NULL 							 COMMENT "Ссылка на сущность",
  user_id 		INT UNSIGNED NOT NULL 							 COMMENT "Ссылка на пользователя, который поставил лайк",
  from_at 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP  	 COMMENT "Время установки лайка",
  till_at 		DATETIME NOT NULL DEFAULT '9999-12-31 23:59:59'  COMMENT "Время удаления лайка", 
  PRIMARY KEY (entity_id, user_id, from_at) 					 COMMENT "Составной первичный ключ"  
) COMMENT "Медиафайлы";


--======================================================================================================================================
-- 3. Используя сервис http://filldb.info или другой по вашему желанию, сгенерировать тестовые данные для всех таблиц, учитывая логику связей. 
-- Для всех таблиц, где это имеет смысл, создать не менее 100 строк. Создать локально БД vk и загрузить в неё тестовые данные.
--======================================================================================================================================

--==========================
-- скрипты урока
--==========================
-- Создаём БД
CREATE DATABASE vk;

-- Делаем её текущей
USE vk;

-- Создаём таблицу пользователей
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
  last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
  email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
  phone VARCHAR(100) NOT NULL UNIQUE COMMENT "Телефон",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Пользователи";  

-- Таблица профилей
CREATE TABLE profiles (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Ссылка на пользователя", 
  gender CHAR(1) NOT NULL COMMENT "Пол",
  birthday DATE COMMENT "Дата рождения",
  photo_id INT UNSIGNED COMMENT "Ссылка на основную фотографию пользователя",
  status VARCHAR(30) COMMENT "Текущий статус",
  city VARCHAR(130) COMMENT "Город проживания",
  country VARCHAR(130) COMMENT "Страна проживания",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Профили"; 

-- Таблица сообщений
CREATE TABLE messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  from_user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на отправителя сообщения",
  to_user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на получателя сообщения",
  body TEXT NOT NULL COMMENT "Текст сообщения",
  is_important BOOLEAN COMMENT "Признак важности",
  is_delivered BOOLEAN COMMENT "Признак доставки",
  created_at DATETIME DEFAULT NOW() COMMENT "Время создания строки",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Сообщения";

-- Таблица дружбы
CREATE TABLE friendship (
  user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на инициатора дружеских отношений",
  friend_id INT UNSIGNED NOT NULL COMMENT "Ссылка на получателя приглашения дружить",
  status_id INT UNSIGNED NOT NULL COMMENT "Ссылка на статус (текущее состояние) отношений",
  requested_at DATETIME DEFAULT NOW() COMMENT "Время отправления приглашения дружить",
  confirmed_at DATETIME COMMENT "Время подтверждения приглашения",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",  
  PRIMARY KEY (user_id, friend_id) COMMENT "Составной первичный ключ"
) COMMENT "Таблица дружбы";

-- Таблица статусов дружеских отношений
CREATE TABLE friendship_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название статуса",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Статусы дружбы";

-- Таблица групп
CREATE TABLE communities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор сроки",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название группы",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Группы";

-- Таблица связи пользователей и групп
CREATE TABLE communities_users (
  community_id INT UNSIGNED NOT NULL COMMENT "Ссылка на группу",
  user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на пользователя",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки", 
  PRIMARY KEY (community_id, user_id) COMMENT "Составной первичный ключ"
) COMMENT "Участники групп, связь между пользователями и группами";

-- Таблица медиафайлов
CREATE TABLE media (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на пользователя, который загрузил файл",
  filename VARCHAR(255) NOT NULL COMMENT "Путь к файлу",
  size INT NOT NULL COMMENT "Размер файла",
  metadata JSON COMMENT "Метаданные файла",
  media_type_id INT UNSIGNED NOT NULL COMMENT "Ссылка на тип контента",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Медиафайлы";

-- Таблица типов медиафайлов
CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name VARCHAR(255) NOT NULL UNIQUE COMMENT "Название типа",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Типы медиафайлов";


--==========================
-- загрузка тестовых данных
--==========================

insert into media_types (name)
select 'gif' as nm union all 
select 'jpeg' as nm union all  
select 'png' as nm union all 
select 'bmp' as nm union all 
select 'tiff' as nm  
;

insert into friendship_statuses (name) 
select 'отправлен запрос' 	as nm union all 
select 'дружба' 			as nm union all  
select 'запрос отклонен' 	as nm union all  
select 'дружба прекращена' 	as nm  
;
 