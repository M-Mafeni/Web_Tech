"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const app = express();
const bodyParser = require('body-parser');
const session = require('express-session');
const port = 8080;
const sqlite = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const df = require('./format');
const xhtml = 'application/xhtml+xml';
const validator = require("email-validator");


//connect to astra.db database
let db = new sqlite.Database('./astra.db');
let OK = 200, NotFound = 404, BadType = 415, Error = 500;

//set views(html layouts) to be your local views directory
app.set('views', './views');
//set handlebars as templating engine
app.set('view engine', 'handlebars');
//set the layouts directory for the handlebars engine
app.engine('handlebars', exphbs({
    layoutsDir: __dirname + '/views/layouts'
}));
//this gives express access to all files in public
app.use(express.static('public'));
//this allows you to parse request bodies
app.use(bodyParser.urlencoded({ extended: true }));
//session is needed to save that a user is logged in
app.use(session({
	secret: 'secret',
	resave: true,
	saveUninitialized: true
}));

app.listen(port, () => console.log(`listening on port ${port}!`));

//for the main page return main.handlebars with its layout being the index page
app.get('/',function (req,res) {
    res.type(xhtml);
    res.render('main',{layout:'index',loggedin:req.session.loggedin});
});

//register page
app.get('/register',function (req,res) {
    if (!req.session.loggedin) {
        res.type(xhtml);
        res.render('main',{layout:'register'})
    }
    else {
        // user shouldn't be able to register when already logged in
        res.redirect("/");
    }
});


app.get('/bookings',function (req,res) {
    /*only go to the bookings page if the user is logged in and they have
     entered a query i.e localhost:8080/bookings.html wouldn't work on its own
    */
    res.type(xhtml);
    if(req.session.loggedin && !isEmpty(req.query)){
        let origin = req.query.origin;
        let destination = req.query.destination;
        let o_date = req.query.outbound_date;
        let d_date = req.query.inbound_date;
        let sql = "SELECT date(origin_date) AS o_date,time(origin_date) as o_time,origin_place,"
         + "date(destination_date) AS d_date,time(destination_date) as d_time,destination_place,price "
          + "FROM Ticket WHERE origin_place = ? AND destination_place = ? AND o_date = ? ";
        db.all(sql,[origin,destination,o_date],(err,o_tickets) => {
            if(err){
                throw err;
            }
            o_tickets.forEach((ticket, i) => {
                ticket.o_date = df.formatDate(ticket.o_date);
                ticket.d_date = df.formatDate(ticket.d_date);
                ticket.o_time = df.formatTime(ticket.o_time);
                ticket.d_time = df.formatTime(ticket.d_time);
            });
            db.all(sql,[destination,origin,d_date], (err,d_tickets) => {
                if(err){
                    throw err;
                }
                d_tickets.forEach((ticket, i) => {
                    ticket.o_date = df.formatDate(ticket.o_date);
                    ticket.d_date = df.formatDate(ticket.d_date);
                    ticket.o_time = df.formatTime(ticket.o_time);
                    ticket.d_time = df.formatTime(ticket.d_time);
                });
                //add tickets attribute to main (used for templating in bookings page)
                res.render('main',{layout:'bookings',
                           o_tickets: o_tickets,
                           d_tickets: d_tickets,
                           loggedin:req.session.loggedin
                        });
            });
        });
    }
    else{
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
            /*for now its sending you to an error page.
            should change this to be a prompt instead*/
            res.send("Incorrect Email");
        }else{
            //password is hashed using bcrypt so hashes need to be compared
            //user.password = hash from db
            bcrypt.compare(password,user.password,function(err,valid){
                if(valid){
                    //user is logged in with that username
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

app.post('/registered',function(req,res){
    // 1. check that email is valid
    // 2. check that email not already registered
    // 3. check if passwords match

    let sql = "SELECT * FROM User WHERE email = ?";
    let insertSQL = db.prepare("INSERT INTO User(email,password) VALUES (?, ?);");
    let email = req.body.email;
    let password = req.body.psw;
    let confirmPassword = req.body.confirm_psw;

    if (validator.validate(email)) {
        db.get(sql,[email],(err,user) => {
            if(user == undefined) {
                if (password == confirmPassword) {
                    bcrypt.hash(password, 10, function(err, hash) {
                        insertSQL.run(email, hash);
                        console.log("user " + email + " registered with password " + hash);

                        // log the new user in
                        req.session.loggedin = true;
                        req.session.username = email;
                        res.redirect("/");
                    });
                }
                else {
                    /*for now its sending you to an error page.
                    should change this to be a prompt instead*/
                    res.send("Passwords do not match");
                }
            }
            else {
                /*for now its sending you to an error page.
                should change this to be a prompt instead*/
                res.send("Email already registered");
            }
        });
    }
    else {
        res.send("Email not valid");
    }
});


app.get('/logout',function (req,res) {
    if (req.session.loggedin) {
        req.session.loggedin = false;
        req.session.username = null;
        res.redirect('/');
    }
    else res.redirect('/');
});
