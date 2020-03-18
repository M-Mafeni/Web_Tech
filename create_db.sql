DROP TABLE IF EXISTS User;

CREATE TABLE User(
    id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    password TEXT,
    first_name TEXT,
    last_name TEXT,
    Address TEXT
);
--passwords stored unencrypted as a test
--will change later
INSERT INTO User(email,password) VALUES
    ("JohnS@hotmail.co.uk","H3LL0W0RLD"),
    ("AshleyA@gmail.com","Duck15"),
    ("JamesKirk@space.co.uk","StarFleet");

DROP TABLE IF EXISTS Ticket;
CREATE TABLE Ticket(
    id INTEGER PRIMARY KEY,
    --thinking that origin and destination could be stored better
    origin_date TEXT, --can store both date and time as a string in sqlite
    origin_place TEXT,
    destination_date TEXT,
    destination_place TEXT,
    price REAL
);

INSERT INTO Ticket(origin_date,origin_place,destination_date,destination_place,price)
VALUES
(datetime("2020-03-22 19:30:00"),"USA",datetime("2020-03-23 08:00:00"),"Mars Colony One",400),
(datetime("2020-04-11 10:00:00"),"Moon Base",datetime("2020-04-24 01:00:00"),"UK",250),
(datetime("2020-03-23 12:30:00"),"UK",datetime("2020-03-24 18:00:00"),"International Space Station",200),
(datetime("2020-03-22 19:30:00"),"Mars Colony One",datetime("2020-03-23 08:00:00"),"Moon Base",350);

DROP TABLE IF EXISTS User_Ticket;
CREATE TABLE User_Ticket(
    user_id INTEGER,
    ticket_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES User(id),
    FOREIGN KEY(ticket_id) REFERENCES Ticket(id)
);
INSERT into User_Ticket
VALUES
(1,1),
(2,1),
(2,2),
(3,4);
