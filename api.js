"use strict";
var express = require('express');
var router = express.Router();
const sqlite = require('sqlite3').verbose();
let db = new sqlite.Database('./astra.db');

router.get('/tickets',function (req,res) {
    let tickets = [];
    let sql = "SELECT * FROM Ticket";
    db.all(sql,[],(err,rows) => {
        if(err){
            throw err;
        }
        res.send(rows);
    });
});

function getTickets(){
    console.log("function called");
    let sql = "SELECT * FROM Ticket";
    db.all(sql,[],(err,rows) => {
        if(err){
            throw err;
        }
//        console.log(rows);
        return rows;
    });
};

module.exports.getTickets = getTickets;
module.exports.db = db;
//module.exports = {
//    router,
//};
