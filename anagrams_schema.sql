CREATE SCHEMA "anagrams" AUTHORIZATION "monetdb";
SET SCHEMA "anagrams";

CREATE TABLE "anagrams".words (
word_id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  word varchar(200) not null,
  monetdb varchar(8192) not null
);


