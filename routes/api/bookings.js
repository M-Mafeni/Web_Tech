const express = require('express');
const router = express.Router();
const df = require('../../helper');
const database = require('../../database');
const db = database.db;

router.get("/", (req, res) => {
    let origin = req.query.origin;
    let destination = req.query.destination;
    let o_date = req.query.outbound_date;
    let d_date = req.query.inbound_date;
    let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
    +   "date(destination_date) AS d_date,time(destination_date) as d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
    +   "FROM Ticket WHERE origin_place = ? AND destination_place = ? AND o_date = ? ORDER BY price"
    db.all(sql,[origin,destination,o_date],(err,o_tickets) => {
      if(err) {
        return res.status(500).send(err);
      }

      o_tickets = df.formatTickets(o_tickets);
      db.all(sql,[destination,origin,d_date], (err,d_tickets) => {
          if(err) {
            return res.status(500).send(err);
          }
          d_tickets = df.formatTickets(d_tickets);
          res.status(200).send({
            outboundTickets: o_tickets,
            inboundTickets: d_tickets,
          });
      });
    });
});

module.exports = router