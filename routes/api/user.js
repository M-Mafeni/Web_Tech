const express = require('express');
const router = express.Router();
const df = require('../../helper');
const database = require('../../database');
const db = database.db;

router.get("/currentUser", (req, res) => {
  let userSQL = "SELECT id, email, first_name,last_name,Address,isAdmin FROM User WHERE email = ?";
  let ticketSQL = "SELECT id, date(origin_date) AS o_date,time(origin_date) AS o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
    + "date(destination_date) AS d_date,time(destination_date) AS d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
    + "FROM (SELECT ticket_id FROM User_Ticket WHERE user_id = ?) INNER JOIN Ticket ON ticket_id = Ticket.id "
    + "ORDER BY o_date DESC, o_time DESC, d_date DESC, d_time DESC";

    db.get(userSQL, [req.session.username], (err, user) => {
      if (err) {
        return res.status(500).send(err);
      }
      if (!user) {
        return res.sendStatus(404);
      }
      db.all(ticketSQL,[user.id],(err2,purchased_tickets) => {
          if (err2) {
            return res.status(500).send(err2);
          }
          purchased_tickets.forEach((ticket) => {
              ticket.o_date = df.formatDate(ticket.o_date);
              ticket.d_date = df.formatDate(ticket.d_date);
              ticket.o_time = df.formatTime(ticket.o_time);
              ticket.d_time = df.formatTime(ticket.d_time);
          });

          user.isAdmin = user.isAdmin === 1;
          user.tickets = purchased_tickets;
          return res.send(user);
        });
    });
});

module.exports = router