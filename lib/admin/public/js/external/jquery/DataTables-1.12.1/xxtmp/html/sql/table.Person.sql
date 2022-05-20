-- 
-- Editor SQL for DB table Person
-- Created by http://editor.datatables.net/generator
-- 

CREATE TABLE IF NOT EXISTS \"Person\" (
	\"id\" serial,
	\"name\" text,
	\"dob\" date,
	\"gender\" numeric(9,2),
	PRIMARY KEY( id )
);