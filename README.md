# Astra - A booking website for commercial space travel

<img src = "public/assets/logo_black_embedded.svg"></img>

This was our submission for the Web Technologies unit. Our website is a booking platform for futuristic space travel, which serves as a central place to display journeys from different rocket airlines, much like how Trainline does for railway transport. 

## Website functionality
Our website consists of a total of four main pages:
- Home page - consists of a booking form and a section describing Astra
- Bookings page - lists all tickets that meet the user's input into the booking form. The user has to be logged in for this
- Confirmation page - lists the final two tickets selected by the user as confirmation. The user also has to be logged in for this
- Registering page - gives the user an opportunity to create a new account

We also have an Account section on the website where logged-in users can view and modify their personal details and previously purchased tickets. For Admin accounts, there are extra pages where Admins can add, modify or remove tickets in the database, as well as grant admin privileges to other accounts.

## Technologies used
We used [ExpressJS](https://expressjs.com/) for the server, and [Handlebars](https://handlebarsjs.com/) for templating the HTML. We also used [Materialize.css](https://materializecss.com/getting-started.html) as the basis of our website's styling, along with [JQuery](https://jquery.com/) for the front-end scripting. For the database, we used an embedded [SQLite](https://www.sqlite.org/index.html) database.

## Requirements
You will need [NodeJS](https://nodejs.org/en/) to run our website, along with the following node modules:
- express
- email-validator

To install these modules, simply run `npm install <module>`.

## Running the website

To run the website, download the repository and run the command `node server.js` in your terminal. It will run on localhost on both port 3000 (HTTPS), and port 8080 (HTTP) (which gets redirected to the HTTPS port). Because we're using a self-signed certificate, your browser may not trust the website, so you may have to download the certificate and tell your browser to trust it.

We have pre-added three accounts, one of which is an Admin, into the database. Below are the credentials of these three accounts:

|         Email         | Password   | Admin |
|:---------------------:|------------|:-----:|
|  JohnS@hotmail.co.uk  | H3LL0W0RLD |  Yes  |
|   AshleyA@gmail.com   |   Duck15   |   No  |
| JamesKirk@space.co.uk |  StarFleet |   No  |

We have also pre-added a number of tickets. Below are four valid ticket combinations:

| Possible Journey |      Origin     |         Destination         | Outbound date | Inbound date |
|:----------------:|:---------------:|:---------------------------:|:-------------:|:------------:|
|         1        |       USA       |       Mars Colony One       |  22 June 2020 | 26 June 2020 |
|         2        |    Moon Base    |              UK             |  11 July 2020 | 19 July 2020 |
|         3        |        UK       | International Space Station |  23 June 2020 |  1 July 2020 |
|         4        | Mars Colony One |          Moon Base          |  22 June 2020 | 29 June 2020 |



