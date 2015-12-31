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
  anagrams string not null
);

DROP TABLE "anagrams".wordjumble;
CREATE TABLE "anagrams".wordjumble (
jid INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  word_id int not null,
  word varchar(200) not null,
  FOREIGN KEY (word_id) REFERENCES "anagrams".words (word_id)
);

SELECT a.word AS jumble, b.word FROM words a JOIN wordjumble b ON (a.word_id = b.word_id) WHERE b.word = 'sarcophagus';

SELECT a.word AS jumble, b.word FROM words a JOIN wordjumble b ON (a.word_id = b.word_id) GROUP by b.word_id, a.word, b.word;
