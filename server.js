"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const app = express();
const app1 = express(); //for http server
const bodyParser = require('body-parser');
const session = require('express-session');
const port = 8080;
const secure_port = 3000;
const sqlite = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const fs = require('fs');
const http = require('http');
const https = require('https');
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


//listen to both http and https ports
const httpServer = http.createServer(app1).listen(port,() => console.log(`listening on port ${port}!`));
// redirect all http requests to https server
app1.get('*',function(req,res){
    res.redirect('https://localhost:3000'+req.url);
});
const httpsServer = https.createServer({
    key: fs.readFileSync('server.key'),
    cert: fs.readFileSync('server.cert')
},app)
.listen(secure_port,() => console.log(`listening on port ${secure_port}! \n Go to https://localhost:3000`));
// app.listen(port, () => console.log(`listening on port ${port}!`));

//for the main page return main.handlebars with its layout being the index page
app.get('/',function (req,res) {
    res.type(xhtml);
    let sql = "SELECT name FROM Destination";
    db.all(sql,[],(err,destinations)=>{
            let prompt = req.session.prompt;
            let result = req.session.result;
            req.session.prompt = null;
            req.session.result = null;
            res.render('main',{layout:'index',loggedin:req.session.loggedin,isAdmin:req.session.isAdmin,destinations:destinations,prompt:prompt,result:result});
        //probably can fuse 2 queries together but might involve filtering returned list
        // let sql1 = "SELECT DISTINCT destination_place FROM Ticket";
        // db.all(sql1,[],(err,inbound)=>{
        //     let prompt = req.session.prompt;
        //     let result = req.session.result;
        //     req.session.prompt = null;
        //     req.session.result = null;
        //     res.render('main',{layout:'index',loggedin:req.session.loggedin,outbound:outbound,inbound:inbound,prompt:prompt,result:result});
        // });
    });
});

app.get('/account',function (req,res) {
    res.type(xhtml);
    if (req.session.loggedin) {
        let userSQL = "SELECT * FROM User WHERE email = ?";
        let ticketSQL = "SELECT id, date(origin_date) AS o_date,time(origin_date) AS o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
         + "date(destination_date) AS d_date,time(destination_date) AS d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
         + "FROM (SELECT ticket_id FROM User_Ticket WHERE user_id = ?) INNER JOIN Ticket ON ticket_id = Ticket.id "
         + "ORDER BY o_date DESC, o_time DESC, d_date DESC, d_time DESC";

        db.get(userSQL, [req.session.username], (err, user) => {
            db.all(ticketSQL,[user.id],(err2,purchased_tickets) => {
                purchased_tickets.forEach((ticket, i) => {
                    ticket.o_date = df.formatDate(ticket.o_date);
                    ticket.d_date = df.formatDate(ticket.d_date);
                    ticket.o_time = df.formatTime(ticket.o_time);
                    ticket.d_time = df.formatTime(ticket.d_time);
                });
                res.render('main',{layout:'account',email:req.session.username,
                            first_name: user.first_name, last_name: user.last_name,
                            address: user.Address, purchased_tickets:purchased_tickets,
                            loggedin:req.session.loggedin});
            });
        });
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'You are not logged in.',result:'prompt-fail'});
    }

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
            +   "FROM Ticket WHERE origin_place = ? AND destination_place = ? AND o_date = ? ORDER BY price DESC"
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
    res.type(xhtml);
    if (req.session.loggedin) {
        let outbound = {id:req.body.out_id, price:req.body.out_price.substring(1), o_date:req.body.out_o_date, d_date:req.body.out_d_date,
                        origin_place:req.body.out_o_loc, destination_place:req.body.out_d_loc,
                        o_time:req.body.out_o_time, d_time:req.body.out_d_time};
        let inbound = {id:req.body.in_id, price:req.body.in_price.substring(1), o_date:req.body.in_o_date, d_date:req.body.in_d_date,
                        origin_place:req.body.in_o_loc, destination_place:req.body.in_d_loc,
                        o_time:req.body.in_o_time, d_time:req.body.in_d_time};
        let finalTickets = {outbound, inbound};

        res.render('main',{layout:'confirmation',loggedin:req.session.loggedin, final_tickets:finalTickets});
    }
    else {
        req.session.prompt= 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'You are not logged in.',result:'prompt-fail'});
    }
});

app.post('/confirmed', function(req,res) {
    res.type(xhtml);
    if (req.session.loggedin) {
        let idSQL = "SELECT id FROM USER WHERE email = ?";
        let sql = db.prepare("INSERT INTO User_Ticket(user_id, ticket_id) VALUES (?, ?)");

        db.get(idSQL,[req.session.username],(err,user) => {
            sql.run(user.id, req.body.out_id);
            sql.run(user.id, req.body.in_id);
        });

        console.log("user purchased tickets with IDs " + req.body.out_id + " and " + req.body.in_id);
        req.session.prompt= 'Ticket purchased.';
        req.session.result = 'prompt-success';
        res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'Ticket purchased.',result:'prompt-success'});
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'You are not logged in.',result:'prompt-fail'});
    }
});

app.post('/login',function(req,res){
    res.type(xhtml);
    let sql = "SELECT * FROM User WHERE email = ?";
    let email =req.body.email;
    let password = req.body.psw;
    db.get(sql,[email],(err,user) => {
        if(user == undefined){
            // setup prompt and render page
            req.session.prompt = 'Email unregistered.';
            req.session.result = 'prompt-fail';
            res.redirect('/');
            // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'Email unregistered.',result:'prompt-fail'});
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
                    req.session.prompt = 'Logged in successfully.';
                    req.session.result = 'prompt-success';

                    // setup prompt and render page
                    // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'Logged in successfully.',result:'prompt-success'});
                    res.redirect('/');
                }
                else{
                    // setup prompt and render page
                    // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'Password incorrect.',result:'prompt-fail'});
                    req.session.prompt = 'Password incorrect.';
                    req.session.result = 'prompt-fail';
                    res.redirect('/');
                }
            });
        }
    });
});

app.post('/registered',function(req,res){
    // 1. check that email is valid
    // 2. check that email not already registered
    // 3. check if passwords match

    res.type(xhtml);
    let sql = "SELECT * FROM User WHERE email = ?";
    let insertSQL = db.prepare("INSERT INTO User(email,password,first_name,last_name,Address) VALUES (?,?,?,?,?);");
    let email = req.body.email;
    let password = req.body.psw;
    let confirmPassword = req.body.confirm_psw;
    let first_name = req.body.first_name;
    let last_name = req.body.last_name;
    let address = req.body.address;

    if (!req.session.loggedin) {
        if (validator.validate(email)) {
            db.get(sql,[email],(err,user) => {
                if(user == undefined) {
                    if (password == confirmPassword) {
                        bcrypt.hash(password, 10, function(err, hash) {
                            insertSQL.run(email,hash,first_name,last_name,address);
                            // console.log("user " + email + " registered with password " + hash);

                            // log the new user in
                            req.session.loggedin = true;
                            req.session.username = email;
                            req.session.prompt = 'Registered and logged in successfully.';
                            req.session.result = 'prompt-success';
                            // setup prompt and render page
                            // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'Registered and logged in successfully.',result:'prompt-success'});
                            res.redirect('/');
                        });
                    }
                    else {
                        // setup prompt and render page
                        req.session.prompt = 'Passwords do not match.';
                        req.session.result = 'prompt-fail';
                        // res.render('main',{layout:'register',prompt:'Passwords do not match.',result:'prompt-fail'})
                        res.redirect('/');
                    }
                }
                else {
                    // setup prompt and render page
                    req.session.prompt = 'Email already registered.';
                    req.session.result = 'prompt-fail';
                    res.redirect('/');
                    // res.render('main',{layout:'register',prompt:'Email already registered.',result:'prompt-fail'})
                }
            });
        }
        else {
            req.session.prompt = 'Email not valid.';
            req.session.result = 'prompt-fail';
            res.redirect('/');
            // res.render('main',{layout:'register',prompt:'Email not valid.',result:'prompt-fail'})
        }
    }
    else {
        res.redirect('/');
    }
});
/*
Add way to update and delete tickets
make pages responsive
*/
app.get('/admin',function(req,res){
    if(req.session.loggedin){
        if(req.session.isAdmin){
            res.type(xhtml);
            let sql = "SELECT name FROM Destination";
            db.all(sql,[],(err,destinations)=>{
                    let prompt = req.session.prompt;
                    let result = req.session.result;
                    // req.session.prompt = null;
                    // req.session.result = null;
                    res.render('main',{layout:'admin',loggedin:req.session.loggedin,isAdmin:req.session.isAdmin,destinations:destinations,prompt:prompt,result:result});
            });
        }else{
            res.status(401).send('not an admin.');
            // req.session.prompt = 'You are not an Admin.';
            // req.session.result = 'prompt-fail';
            // res.redirect('/');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }

});
app.post('/admin/addticket',function(req,res){
    if(req.session.loggedin){
        if(req.session.isAdmin){
            let origin = req.body.origin;
            let destination = req.body.destination;
            let o_date = req.body.outbound_date;
            let o_time = req.body.outbound_time;
            let o_date_time = o_date + " " + o_time;
            let d_date = req.body.inbound_date;
            let d_time = req.body.inbound_time;
            let d_date_time = d_date + " " + d_time;
            let price = req.body.price;

            // console.log(o_date_time);
            // console.log(o_time);
            let insertTicketSQL = db.prepare("INSERT INTO Ticket(origin_date,origin_id,destination_date,destination_id,price) VALUES (datetime(?),?,datetime(?),?,?)");
            let id_sql = "SELECT t1.id AS o_id, t2.id AS d_id FROM  Destination as t1 INNER JOIN Destination as t2 WHERE t1.name = ? AND t2.name = ?"
            //get destination IDs
            db.get(id_sql, [origin,destination],(err,ids)=>{
                if(ids!== undefined){
                    let o_id = ids.o_id;
                    let d_id = ids.d_id;
                    // console.log(o_id);
                    // console.log(d_id);
                    insertTicketSQL.run(o_date_time,o_id,d_date_time,d_id,price);
                    req.session.prompt = 'Ticket added.';
                    req.session.result = 'prompt-success';
                }else{
                    req.session.prompt = 'Destination not valid.';
                    req.session.result = 'prompt-fail';
                }
                res.redirect('/admin');

                console.log(ids);

            });
        }else{
            res.status(401).send('not an admin.');
            // req.session.prompt = 'You are not an Admin.';
            // req.session.result = 'prompt-fail';
            // res.redirect('/');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
app.post('/admin/destination',function(req,res){
    if(req.session.loggedin){
        if(req.session.isAdmin){
            let name = req.body.destination;
            let sql = "INSERT INTO Destination(name) VALUES(?)";
            db.run(sql,[name],function(err){
                if(!err){
                    req.session.prompt = 'New Destination added';
                    req.session.result = 'prompt-success';
                }else{
                    req.session.prompt = 'Destination already exists.';
                    req.session.result = 'prompt-fail';
                }
                res.redirect('/admin');
            });
        }else{
            res.status(401).send('not an admin.');
            // req.session.prompt = 'You are not an Admin.';
            // req.session.result = 'prompt-fail';
            // res.redirect('/');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
app.get('/admin/tickets',function(req,res){
    if(req.session.loggedin){
        if(req.session.isAdmin){
            //get all tickets
            // let sql = "SELECT * FROM Ticket ORDER BY origin_date DESC";
            let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
            +   "date(destination_date) AS d_date,time(destination_date) as d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
            +   "FROM Ticket ORDER BY origin_date DESC";
            db.all(sql,[],(err,tickets)=>{
                res.render('main',{layout:'update_tickets',loggedin:req.session.loggedin,isAdmin:req.session.isAdmin,tickets:tickets});
            });
        }else{
            res.status(401).send('not an admin.');
            // req.session.prompt = 'You are not an Admin.';
            // req.session.result = 'prompt-fail';
            // res.redirect('/');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
app.get('/logout',function (req,res) {
    if (req.session.loggedin) {
        req.session.loggedin = false;
        req.session.username = null;
        req.session.isAdmin = false;
        // setup prompt and render page
        res.type(xhtml);
        req.session.prompt = 'Logged out successfully.';
        req.session.result='prompt-success';
        // res.redirect('/');
        // res.render('main',{layout:'index',loggedin:req.session.loggedin,prompt:'Logged out successfully.',result:'prompt-success'});
    }
    res.redirect('/');
});

function isEmpty(obj){
    return Object.keys(obj).length === 0;
}
