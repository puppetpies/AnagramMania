CREATE USER "anagrams" WITH PASSWORD 'dk3rbi9L' NAME 'Anagrams' SCHEMA "sys";
CREATE SCHEMA "anagrams" AUTHORIZATION "anagrams";
ALTER USER "anagrams" SET SCHEMA "anagrams";
SET SCHEMA "anagrams";


CREATE TABLE "anagrams".words (
word_id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  word varchar(200) not null,
  anagrams varchar(8192) not null
);


