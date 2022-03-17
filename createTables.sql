/* USER Testing */
/* Valid */
INSERT INTO USER(Email, NickName, Profile)
VALUES ('gtang936@mtroyal.ca', 'Sam', 'Nothing');

/* Invalid: NickName exceeds the domain */
INSERT INTO USER(Email, NickName, Profile)
VALUES ('ktang936@mtroyal.ca', 'KenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKenKen', 'Nothing');

/* Invalid: Primary Key duplicated */
INSERT INTO USER(Email, NickName, Profile)
VALUES ('gtang936@mtroyal.ca', 'Michael', 'Nothing');

/* Valid */
INSERT INTO USER(Email, NickName, Profile)
VALUES ('ttang936@mtroyal.ca', 'Tom', 'Nothing');

/* Invalid Update: Email and DateAdded is not allowed to update */
UPDATE USER SET Email='gtang936@yahoo.com.hk' WHERE Email='gtang936@mtroyal.ca';

UPDATE USER SET DateAdded='2030-01-01' WHERE email='ttang936@mtroyal.ca';

/* AUTHOR Testing */
/* Invalid: do not insert all the necessary column */
INSERT INTO AUTHOR(LastName)
VALUES ('William');

/* Add a book with multiple authors */
INSERT INTO BOOK(Title, Year)
VALUES
       ('The Essence of Database', 2021),
       ('The Essence of Programming', 2020),
       ('I am no Shakespeare', 2019);

INSERT INTO AUTHOR(LastName, FirstName, DOB)
VALUES
       ('Shakespeare', 'William', '1564-04-26'),
       ('Dickinson', 'Emily', '1830-12-10'),
       ('Tolstoy','Leo','1828-09-09'),
       ('Shakespeare', 'Tyler', '2000-01-01');

INSERT INTO BOOKAUTHOR(AuthorID, BookID)
VALUES
       (1,1),
       (2,1),
       (3,2),
       (4,3);

/* This would look for the book title of 'The Essence of Database'
and show the author's last name and DOB */
DROP VIEW IF EXISTS LookUpByBook;
CREATE VIEW IF NOT EXISTS LookUpByBook AS
SELECT BOOK.Title AS Book_Title, BOOK.BookID AS Book_ID, AUTHOR.LastName AS Author_Last_Name, AUTHOR.DOB AS Author_Date_Of_Birth
FROM BOOK
JOIN BOOKAUTHOR ON(BOOK.BookID = BOOKAUTHOR.BookID)
JOIN AUTHOR ON(BOOKAUTHOR.AuthorID = AUTHOR.AuthorID)
WHERE BOOK.Title = 'The Essence of DataBase';

SELECT * FROM LookUpByBook;

/* This would look for authors whose last name is 'Shakespeare' and the book they wrote */
DROP VIEW IF EXISTS LookUpByAuthor;
CREATE VIEW IF NOT EXISTS LookUpByAuthor AS
SELECT AUTHOR.LastName AS Author_Last_Name, AUTHOR.FirstName AS Author_First_Name, BOOK.Title AS Book_Title, BOOK.BookID AS Book_ID
FROM BOOK
JOIN BOOKAUTHOR ON(BOOK.BookID = BOOKAUTHOR.BookID)
JOIN AUTHOR ON(BOOKAUTHOR.AuthorID = AUTHOR.AuthorID)
WHERE AUTHOR.LastName = 'Shakespeare';

SELECT * FROM LookUpByAuthor;

/* Have two users ’read’ and rate a book.
Show that domain constraints are being met and all statistics have been updated. */
DROP VIEW IF EXISTS CheckRatingUpdate;
CREATE VIEW IF NOT EXISTS CheckRatingUpdate AS
SELECT BOOK.Title As Title, BOOK.NumRaters AS Number_Of_Raters, BOOK.Rating AS Rating
FROM BOOK;

/* Result before rating */
SELECT * FROM CheckRatingUpdate;

/* Valid user */
INSERT INTO READBOOK(BookID, Email, Rating)
VALUES
       (1, 'ttang936@mtroyal.ca', 7);

/* Result after 1 user's rating */
SELECT * FROM CheckRatingUpdate;

/* Valid user */
INSERT INTO READBOOK(BookID, Email, Rating)
VALUES (1, 'gtang936@mtroyal.ca', 8);

/* Result after 2 users' rating */
SELECT * FROM CheckRatingUpdate;

/* Invalid: rating is out of range */
INSERT INTO READBOOK(BookID, Email, Rating)
VALUES (2, 'ttang936@mtroyal.ca', 13);

INSERT INTO READBOOK(BookID, Email, Rating)
VALUES (2, 'gtang936@mtroyal.ca', 6);

SELECT * FROM CheckRatingUpdate;

/* Delete one of the ’read’ records just entered and show that
all statistics have been updated. */
DELETE FROM READBOOK WHERE Email = 'ttang936@mtroyal.ca';

SELECT * FROM CheckRatingUpdate;
