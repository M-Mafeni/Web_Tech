"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const app = express();
const bodyParser = require('body-parser');
const session = require('express-session');
const port = 8080;
const sqlite = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const df = require('./format')

let db = new sqlite.Database('./astra.db');
let OK = 200, NotFound = 404, BadType = 415, Error = 500;

app.set('views', './views');
app.set('view engine', 'handlebars');

app.engine('handlebars', exphbs({
    layoutsDir: __dirname + '/views/layouts'
}));
app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
	secret: 'secret',
	resave: true,
	saveUninitialized: true
}));

app.listen(port, () => console.log(`listening on port ${port}!`));

app.get('/',function (req,res) {
    res.render('main',{layout:'index'});
});

app.get('/bookings.html',function (req,res) {
    if(req.session.loggedIn|| !isEmpty(req.query)){
        let origin = req.query.origin;
        let destination = req.query.destination;
        let date = req.query.date;
        let sql = "SELECT date(origin_date) AS o_date,time(origin_date) as o_time,origin_place,"
         + "date(destination_date) AS d_date,time(destination_date) as d_time,destination_place,price "
          + "FROM Ticket WHERE origin_place = ? AND destination_place = ? AND o_date = ? ";
        db.all(sql,[origin,destination,date],(err,tickets) => {
            if(err){
                throw err;
            }
            tickets.forEach((ticket, i) => {
                ticket.o_date = df.formatDate(ticket.o_date);
                ticket.d_date = df.formatDate(ticket.d_date);
            });

            res.render('main',{layout:'bookings',
                       tickets: tickets  });
        });
    }else{
        res.redirect("/");
    }

});
function isEmpty(obj){
    return Object.keys(obj).length === 0;
}
app.post('/login',function(req,res){
    let sql = "SELECT * FROM User WHERE email = ?";
    let email =req.body.email;
    let password = req.body.psw;
    db.get(sql,[email],(err,user) => {
        if(user == undefined){
            res.send("Incorrect Email");
        }else{
            bcrypt.compare(password,user.password,function(err,valid){
                if(valid){
                    req.session.loggedin = true;
                    req.session.username = email;
                    res.redirect('/');
                }else{
                    res.send("Invalid Password");
                }
            });
        }
    });
});
