/* Drop the tables */
DROP TABLE IF EXISTS USER;

/* Create an USER table */
CREATE TABLE IF NOT EXISTS USER(
Email VARCHAR(50) UNIQUE,
DateAdded DATE NOT NULL DEFAULT(NOW()),
NickName VARCHAR(20),
Profile VARCHAR(100))
ENGINE=InnoDB;

/* Set the primary key */
ALTER TABLE USER ADD CONSTRAINT USER_pk
PRIMARY KEY (Email);

/* Create a trigger to prevent user from updating Email and DateAdded */
DROP TRIGGER IF EXISTS user_data_authority_BUR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS user_data_authority_BUR
BEFORE UPDATE on USER
FOR EACH ROW
BEGIN
  IF OLD.Email <> NEW.Email
  OR OLD.DateAdded <> NEW.DateAdded
  THEN SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Email and DateAdded are not allowed to update.';
  END IF;
END$$
DELIMITER ;

/* Drop the tables */
DROP TABLE IF EXISTS BOOK;

/* Create a BOOK table */
CREATE TABLE IF NOT EXISTS BOOK(
BookID INT AUTO_INCREMENT PRIMARY KEY,
Title VARCHAR(100) NOT NULL,
Year INT(4) NOT NULL,
NumRaters INT DEFAULT(0),
Rating DECIMAL(3,1))
ENGINE=InnoDB;

/* Drop the tables */
DROP TABLE IF EXISTS AUTHOR;

/* Create an AUTHOR table */
CREATE TABLE IF NOT EXISTS AUTHOR(
AuthorID INT AUTO_INCREMENT PRIMARY KEY,
LastName VARCHAR(20),
FirstName VARCHAR(20) NOT NULL,
MiddleName VARCHAR(20),
DOB DATE)
ENGINE=InnoDB;

/* Drop the tables */
DROP TABLE IF EXISTS BOOKAUTHOR;

/* Create a BOOKAUTHOR table */
CREATE TABLE IF NOT EXISTS BOOKAUTHOR(
AuthorID INT,
BookID INT)
ENGINE=InnoDB;

/* Set the primary key */
ALTER TABLE BOOKAUTHOR ADD CONSTRAINT BOOKAUTHOR_pk
PRIMARY KEY (AuthorID, BookID);

/* Set the foreign key AuthorID referencing AUTHOR table*/
ALTER TABLE BOOKAUTHOR ADD CONSTRAINT BOOKAUTHOR_AuthorID_fk
FOREIGN KEY (AuthorID) REFERENCES AUTHOR(AuthorID);

/* Set the foreign key BookID referencing BOOK table */
ALTER TABLE BOOKAUTHOR ADD CONSTRAINT BOOKAUTHOR_BookID_fk
FOREIGN KEY (BookID) REFERENCES BOOK(BookID);

/* Drop the tables */
DROP TABLE IF EXISTS READBOOK;

/* Create an READBOOK table */
CREATE TABLE IF NOT EXISTS READBOOK(
BookID INT,
Email VARCHAR(100),
DateRead DATE NOT NULL DEFAULT(NOW()),
Rating INT)
ENGINE=InnoDB;

/* Set the primary key */
ALTER TABLE READBOOK ADD CONSTRAINT READBOOK_pk
PRIMARY KEY (BookID, Email);

/* Set the foreign key BookID referencing BOOK table */
ALTER TABLE READBOOK ADD CONSTRAINT READBOOK_BookID_fk
FOREIGN KEY (BookID) REFERENCES BOOK(BookID);

/* Set the foreign key Email referencing USER table */
ALTER TABLE READBOOK ADD CONSTRAINT READBOOK_Email_pk
FOREIGN KEY (Email) REFERENCES USER(Email);

/* Set the constraint to the rating */
ALTER TABLE READBOOK ADD CONSTRAINT READBOOK_Rating_Column_Range
CHECK (Rating >= 0 AND Rating <= 10);

/* When a user is deleted all of the READBOOK records associated with the user must also be deleted */
DROP TRIGGER IF EXISTS delete_asso_ADR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS delete_asso_ADR
AFTER DELETE on USER
FOR EACH ROW
BEGIN
  DELETE FROM READBOOK WHERE Email = OLD.Email;
END$$
DELIMITER ;

/* The total number of users who have rated this book.
This is a derived field as it is the count of
rows in READBOOK for this particular book */
DROP TRIGGER IF EXISTS number_of_raters_AIR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS number_of_raters_AIR
AFTER INSERT on READBOOK
FOR EACH ROW
BEGIN
  UPDATE BOOK SET NumRaters = (SELECT COUNT(*)
    FROM READBOOK
    WHERE BookID = NEW.BookID)
  WHERE BookID = NEW.BookID;
END$$
DELIMITER ;

/* The average of all the ratings on this book.
This is a derived field as it is the average of all the ratings in
READBOOK for this particular book */
DROP TRIGGER IF EXISTS average_rating_AIR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS average_rating_AIR
AFTER INSERT on READBOOK
FOR EACH ROW
BEGIN
  UPDATE BOOK SET Rating = (SELECT AVG(Rating)
    FROM READBOOK
    WHERE BookID = NEW.BookID)
  WHERE BookID = NEW.BookID;
END$$
DELIMITER ;

/* Whenever a row is inserted, deleted or modified
the corresponding row in BOOK, NumRaters and Rating must
be updated. Unless noted all fields are required */
DROP TRIGGER IF EXISTS number_of_raters_AUR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS number_of_raters_AUR
AFTER UPDATE on READBOOK
FOR EACH ROW
BEGIN
  UPDATE BOOK SET NumRaters = (SELECT COUNT(*)
    FROM READBOOK
    WHERE BookID = NEW.BookID)
  WHERE BookID = NEW.BookID;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS average_rating_AUR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS average_rating_AUR
AFTER UPDATE on READBOOK
FOR EACH ROW
BEGIN
  UPDATE BOOK SET Rating = (SELECT AVG(Rating)
    FROM READBOOK
    WHERE BookID = NEW.BookID)
  WHERE BookID = NEW.BookID;
END$$
DELIMITER ;


all statistics have been updated */
DROP TRIGGER IF EXISTS number_of_raters_ADR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS number_of_raters_ADR
AFTER DELETE on READBOOK
FOR EACH ROW
BEGIN
  UPDATE BOOK SET NumRaters = (SELECT COUNT(*)
    FROM READBOOK
    WHERE BookID = OLD.BookID)
  WHERE BookID = OLD.BookID;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS average_rating_ADR;
DELIMITER $$
CREATE TRIGGER IF NOT EXISTS average_rating_ADR
AFTER DELETE on READBOOK
FOR EACH ROW
BEGIN
  UPDATE BOOK SET Rating = (SELECT AVG(Rating)
    FROM READBOOK
    WHERE BookID = OLD.BookID)
  WHERE BookID = OLD.BookID;
END$$
DELIMITER ;
