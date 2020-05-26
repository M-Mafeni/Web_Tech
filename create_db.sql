DROP TABLE IF EXISTS User;

CREATE TABLE User(
    id INTEGER PRIMARY KEY,
    email TEXT UNIQUE,
    password TEXT,
    first_name TEXT,
    last_name TEXT,
    Address TEXT,
    --sqlite doesn't have a separate boolean datatype
    -- (1 = true, 0 = false)
    isAdmin Integer
);

INSERT INTO User(email,password,first_name,last_name,Address,isAdmin) VALUES
    ("JohnS@hotmail.co.uk","$2b$10$bk/1afHVab43.J941yYsjeovFhGQBcf6O5.dhaCxGVTO1jD1ELFua","John","Smith","33 Cross Drive, London, W5D14",1),
    ("AshleyA@gmail.com","$2b$10$JqGO/7vannEgyeMQL3eJXucXHrWtow8EusU8KP4rUnYjKonbCG1FO","Ashley","Axel","11 Grimms Way, Leeds, LS11ED",0),
    ("JamesKirk@space.co.uk","$2b$10$n39S2WJWJDObx0.efj6Mlur3xnPv/jmUxQ3zLyzv1OOAcUVETnf7.","James","Kirk","9 Star Place, Guildford, GU12EX",0);

DROP TABLE IF EXISTS Destination;
CREATE TABLE Destination(
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE
);
INSERT INTO Destination(name) VALUES
    ("USA"),
    ("Moon Base"),
    ("UK"),
    ("Mars Colony One"),
    ("International Space Station");
DROP TABLE IF EXISTS Ticket;
CREATE TABLE Ticket(
    id INTEGER PRIMARY KEY,
    origin_date TEXT, --can store both date and time as a string in sqlite
    origin_id INTEGER,
    destination_date TEXT,
    destination_id INTEGER,
    price REAL CHECK(price>0),
    CHECK (origin_date < destination_date),
    -- using the name as a key instead would lead to better queries
    -- but I saw something online saying that should only be done if the strings never goning to change
    FOREIGN KEY(origin_id) REFERENCES Destination(id),
    FOREIGN KEY(destination_id) REFERENCES Destination(id)
);

INSERT INTO Ticket(origin_date,origin_id,destination_date,destination_id,price)
VALUES
(datetime("2020-06-22 19:30:00"),1,datetime("2020-06-23 08:00:00"),4,800),
(datetime("2020-06-22 10:30:00"),1,datetime("2020-06-23 23:00:00"),4,500),
(datetime("2020-06-22 22:30:00"),1,datetime("2020-06-23 11:00:00"),4,800),

(datetime("2020-06-26 11:30:00"),4,datetime("2020-06-27 08:00:00"),1,700),
(datetime("2020-06-26 14:00:00"),4,datetime("2020-06-27 10:30:00"),1,700),
(datetime("2020-06-26 18:30:00"),4,datetime("2020-06-27 14:30:00"),1,700),

(datetime("2020-07-11 10:00:00"),2,datetime("2020-07-12 01:00:00"),3,500),
(datetime("2020-07-11 07:00:00"),2,datetime("2020-07-11 22:00:00"),3,650),
(datetime("2020-07-11 17:00:00"),2,datetime("2020-07-12 08:00:00"),3,750),

(datetime("2020-07-19 17:00:00"),3,datetime("2020-07-20 08:00:00"),2,750),
(datetime("2020-07-19 12:30:00"),3,datetime("2020-07-20 03:00:00"),2,500),
(datetime("2020-07-19 20:00:00"),3,datetime("2020-07-20 11:00:00"),2,750),

(datetime("2020-06-23 12:30:00"),3,datetime("2020-06-24 18:00:00"),5,600),
(datetime("2020-06-23 08:15:00"),3,datetime("2020-06-24 13:45:00"),5,550),
(datetime("2020-06-23 22:30:00"),3,datetime("2020-06-26 04:00:00"),5,700),

(datetime("2020-07-01 09:00:00"),5,datetime("2020-07-02 09:00:00"),3,400),
(datetime("2020-07-01 14:00:00"),5,datetime("2020-07-02 14:00:00"),3,500),
(datetime("2020-07-01 18:00:00"),5,datetime("2020-07-02 18:00:00"),3,550),

(datetime("2020-06-22 19:30:00"),4,datetime("2020-06-23 08:00:00"),2,550),
(datetime("2020-06-22 10:30:00"),4,datetime("2020-06-22 23:00:00"),2,600),
(datetime("2020-06-22 06:15:00"),4,datetime("2020-06-22 18:45:00"),2,850),

(datetime("2020-06-29 19:30:00"),2,datetime("2020-06-30 08:00:00"),4,700),
(datetime("2020-06-29 10:30:00"),2,datetime("2020-06-30 23:00:00"),4,500),
(datetime("2020-06-29 06:15:00"),2,datetime("2020-06-30 18:45:00"),4,900);





DROP TABLE IF EXISTS User_Ticket;
CREATE TABLE User_Ticket(
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    ticket_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES User(id),
    FOREIGN KEY(ticket_id) REFERENCES Ticket(id)
);

-- INSERT into User_Ticket
-- VALUES
-- (1,1),
-- (2,1),
-- (2,2),
-- (3,4);
