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
--passwords stored unencrypted as a test
--will change later
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
    -- using the name as a key instead would lead to better queries
    -- but I saw something online saying that should only be done if the strings never goning to change
    FOREIGN KEY(origin_id) REFERENCES Destination(id),
    FOREIGN KEY(destination_id) REFERENCES Destination(id)
);

INSERT INTO Ticket(origin_date,origin_id,destination_date,destination_id,price)
VALUES
(datetime("2020-03-22 19:30:00"),1,datetime("2020-03-23 08:00:00"),4,400),
(datetime("2020-04-11 10:00:00"),2,datetime("2020-04-24 01:00:00"),3,250),
(datetime("2020-03-23 12:30:00"),3,datetime("2020-03-24 18:00:00"),5,200),
(datetime("2020-03-22 19:30:00"),4,datetime("2020-03-23 08:00:00"),2,350),
(datetime("2020-03-26 11:30:00"),4,datetime("2020-03-27 08:00:00"),1,350);


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
