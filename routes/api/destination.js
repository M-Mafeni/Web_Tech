"use strict";
const express = require('express');
const router = express.Router();
const database = require('../../database');
const db = database.db;

router.get('/', (req, res) => {
  if (!req.session.loggedin) {
    return res.sendStatus(403);
  }
  let sql = "SELECT * FROM Destination";
  db.all(sql,[],(err,destinations)=> {
    if (err != null) {
      return res.status(500).send(err);
    }
    res.send(destinations);
  });
});

module.exports = router;