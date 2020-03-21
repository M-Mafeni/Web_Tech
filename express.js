"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const api = require('./api');
const app = express();
const bodyParser = require('body-parser');
const port = 8080;
const sqlite = require('sqlite3').verbose();
let db = new sqlite.Database('./astra.db');
let OK = 200, NotFound = 404, BadType = 415, Error = 500;

app.set('views', './views');
app.set('view engine', 'handlebars');

app.engine('handlebars', exphbs({
    layoutsDir: __dirname + '/views/layouts'
}));
app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: true }));

app.listen(port, () => console.log(`listening on port ${port}!`));

app.get('/',function (req,res) {
    res.render('main',{layout:'index'});
});

app.get('/bookings.html',function (req,res) {
    let origin = req.query.origin;
    let destination = req.query.destination;
    let date = req.query.date;
    console.log(date);
    let sql = "SELECT * FROM Ticket WHERE origin_place = ? AND destination_place = ? AND date(origin_date) = ? ";
    db.all(sql,[origin,destination,date],(err,tickets) => {
        if(err){
            throw err;
        }
        res.render('main',{layout:'bookings',
                   tickets: tickets  });
    });
});

app.post('/login',function(req,res){
    let sql = "SELECT * FROM User WHERE email = ? AND password = ?";
    let email =req.body.email;
    let password = req.body.psw;
    db.get(sql,[email,password],(err,user) => {
    if(user != undefined){
        res.redirect('/');
    }else{
        res.redirect('/login?error');
    }
    });
});

app.get('/login',function(req,res){
    res.redirect('/');
})

