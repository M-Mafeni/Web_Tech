"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const app = express();
const app1 = express(); //for http server
const bodyParser = require('body-parser');
const session = require('express-session');
const port = 8080;
const secure_port = 3000;
const xhtml = 'application/xhtml+xml';
const html = 'text/html';
const utf8 = 'utf-8';

const bcrypt = require('bcrypt');
const fs = require('fs');
const http = require('http');
const https = require('https');
const df = require('./helper');
const validator = require("email-validator");
const account = require('./controllers/account.js');
const admin = require('./controllers/admin.js');
const database = require('./database');

//connect to astra.db database
// const sqlite = require('sqlite3').verbose();
// let db = new sqlite.Database('./astra.db');
let db = database.db;
let OK = 200, NotFound = 404, BadType = 415, Error = 500;

//set views(html layouts) to be your local views directory
app.set('views', './views');
//set handlebars as templating engine
app.set('view engine', 'handlebars');
//set the layouts directory for the handlebars engine
app.engine('handlebars', exphbs({
    layoutsDir: __dirname + '/views/layouts'
}));

//make urls case sensitive
app.set('case sensitive routing', true);
//this gives express access to all files in public
app.use(express.static('public'));
//this allows you to parse request bodies
app.use(express.urlencoded({
    extended: true
}));

app.use(express.json());
//session is needed to save that a user is logged in
app.use(session({
	secret: 'secret',
	resave: true,
	saveUninitialized: true
}));


//listen to both http and https ports
const httpServer = http.createServer(app1).listen(port,() => console.log(`listening on port ${port}!`));
// redirect all http requests to https server
app1.all('*',function(req,res){
    res.redirect('https://localhost:3000'+req.url);
});

const httpsServer = https.createServer({
    key: fs.readFileSync('server.key'),
    cert: fs.readFileSync('server.cert')
},app)
.listen(secure_port,() => console.log(`listening on port ${secure_port}! \n Go to https://localhost:3000`));

//for the main page return main.handlebars with its layout being the index page
app.get('/',function (req,res) {
    res = df.setResponseHeader(req, res);

    let sql = "SELECT name FROM Destination";
    db.all(sql,[],(err,destinations)=> {
            res.render('main',{layout:'index', title: "Astra | Home"});
    });
});

app.use('/account',account);

//register page
app.get('/register',function (req,res) {
    res = df.setResponseHeader(req, res);

    if (!req.session.loggedin) {
        let prompt = req.session.prompt;
        let result = req.session.result;
        req.session.prompt = null;
        req.session.result = null;
        res.render('main',{layout:'index'});
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
    res = df.setResponseHeader(req, res);

    if(req.session.loggedin){
        if(!isEmpty(req.query)){
            let origin = req.query.origin;
            let destination = req.query.destination;
            let o_date = req.query.outbound_date;
            let d_date = req.query.inbound_date;
            // let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,origin_place,"
            //  + "date(destination_date) AS d_date,time(destination_date) as d_time,destination_place,price "
            //   + "FROM Ticket WHERE origin_place = ? AND destination_place = ? AND o_date = ? ORDER BY price DESC";
            let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
            +   "date(destination_date) AS d_date,time(destination_date) as d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
            +   "FROM Ticket WHERE origin_place = ? AND destination_place = ? AND o_date = ? ORDER BY price"
            db.all(sql,[origin,destination,o_date],(err,o_tickets) => {
                if(err){
                    throw err;
                }
                o_tickets = df.formatTickets(o_tickets);
                db.all(sql,[destination,origin,d_date], (err,d_tickets) => {
                    if(err){
                        throw err;
                    }
                    d_tickets = df.formatTickets(d_tickets);
                    //add tickets attribute to main (used for templating in bookings page)
                    res.render('main',{layout:'bookings',
                               o_tickets: o_tickets,
                               d_tickets: d_tickets,
                               loggedin:req.session.loggedin,
                               isAdmin:req.session.isAdmin
                            });
                });
            });
        }
        else {
            res.redirect('/');
        }
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'You are not logged in.',result:'prompt-fail'});
    }

});

app.post('/confirmation',function (req,res) {
    res = df.setResponseHeader(req, res);

    if (req.session.loggedin) {
        let outbound = {id:req.body.out_id, price:req.body.out_price.substring(1), o_date:req.body.out_o_date, d_date:req.body.out_d_date,
                        origin_place:req.body.out_o_loc, destination_place:req.body.out_d_loc,
                        o_time:req.body.out_o_time, d_time:req.body.out_d_time};
        let inbound = {id:req.body.in_id, price:req.body.in_price.substring(1), o_date:req.body.in_o_date, d_date:req.body.in_d_date,
                        origin_place:req.body.in_o_loc, destination_place:req.body.in_d_loc,
                        o_time:req.body.in_o_time, d_time:req.body.in_d_time};
        let finalTickets = {outbound, inbound};
        let total = Number(req.body.out_price.substring(1)) + Number(req.body.in_price.substring(1));
        console.log(total);
        res.render('main',{layout:'confirmation',loggedin:req.session.loggedin, final_tickets:finalTickets,isAdmin:req.session.isAdmin,total:total});
    }
    else {
        req.session.prompt= 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

app.post('/confirmed', function(req,res) {
    if (req.session.loggedin) {
        let idSQL = "SELECT id FROM USER WHERE email = ?";
        let sql = db.prepare("INSERT INTO User_Ticket(user_id, ticket_id) VALUES (?, ?)");

        db.get(idSQL,[req.session.username],(err,user) => {
            sql.run(user.id, req.body.source_id);
            sql.run(user.id, req.body.dest_id);
            req.session.prompt= 'Tickets purchased.';
            req.session.result = 'prompt-success';
            res.redirect('/');
        });
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'You are not logged in.',result:'prompt-fail'});
    }
});

app.post('/login',function(req,res) {
    let sql = "SELECT * FROM User WHERE email = ?";
    let email = req.body.email;
    let password = req.body.psw;
    db.get(sql,[email],(err,user) => {
        if(user == undefined) {
            res.status(404);
            res.send({
                error: "Email unregistered"
            })
        }
        else{
            //password is hashed using bcrypt so hashes need to be compared
            //user.password = hash from db
            bcrypt.compare(password,user.password,function(err,valid){
                if(valid){
                    //user is logged in with that username
                    req.session.loggedin = true;
                    req.session.username = email;
                    req.session.isAdmin = user.isAdmin;
                    res.status(200);
                    res.send({
                        isLoggedIn: true,
                        isAdmin: user.isAdmin === 1,
                    });
                }
                else{
                    // setup prompt and render page
                    res.status(403);
                    res.send({error: "Password Incorrect"});
                }
            });
        }
    });
});

app.post('/registered',function(req,res){
    // 1. check that email is valid
    // 2. check that email not already registered
    // 3. check if passwords match

    let insertSQL = "INSERT INTO User(email,password,first_name,last_name,Address) VALUES (?,?,?,?,?)";
    let email = req.body.email;
    let password = req.body.psw;
    let confirmPassword = req.body.confirm_psw;
    let first_name = req.body.first_name;
    let last_name = req.body.last_name;
    let address = req.body.address;

    if (!req.session.loggedin) {
        if (validator.validate(email)) {
            if(password === confirmPassword){
                bcrypt.hash(password, 10, function(err, hash) {
                    db.run(insertSQL,[email,hash,first_name,last_name,address],function (err){
                        if(err){
                            req.session.prompt = 'Email already registered.';
                            req.session.result = 'prompt-fail';
                            res.redirect('/register');
                        }else{
                            req.session.loggedin = true;
                            req.session.username = email;
                            req.session.prompt = 'Registered and logged in successfully.';
                            req.session.result = 'prompt-success';
                            res.redirect('/');
                        }
                    });
                });
            }else{
                req.session.prompt = 'Passwords do not match.';
                req.session.result = 'prompt-fail';
                // res.render('main',{layout:'register',prompt:'Passwords do not match.',result:'prompt-fail'})
                res.redirect('/register');
            }
        }
        else {
            req.session.prompt = 'Email not valid.';
            req.session.result = 'prompt-fail';
            res.redirect('/register');
            // res.render('main',{layout:'register',prompt:'Email not valid.',result:'prompt-fail'})
        }
    }
    else {
        res.redirect('/');
    }
});

app.use('/admin',admin);

app.get('/logout',function (req,res) {
    if (req.session.loggedin) {
        req.session.loggedin = false;
        req.session.username = null;
        req.session.isAdmin = false;
        // setup prompt and render page
        req.session.prompt = 'Logged out successfully.';
        req.session.result='prompt-success';
    }
    res.redirect('/');
});

function isEmpty(obj){
    return Object.keys(obj).length === 0;
}
