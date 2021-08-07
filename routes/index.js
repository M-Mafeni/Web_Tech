const express = require('express');
const router = express.Router();
const validator = require("email-validator");
const bcrypt = require('bcrypt');
const df = require('../helper');
const database = require('../database');
const db = database.db;
// Controllers
const account = require('./controllers/account.js');
const admin = require('./controllers/admin.js');
const api = require("./api");


router.use('/admin', admin);
router.use('/account', account);
router.use("/api", api);

//for the main page return main.handlebars with its layout being the index page
router.get('/',function (req,res) {
  res = df.setResponseHeader(req, res);
  res.render('main',{layout:'index', title: "Astra | Home"});
});


//register page
router.get('/register',function (req,res) {
  res = df.setResponseHeader(req, res);
  if (!req.session.loggedin) {
      req.session.prompt = null;
      req.session.result = null;
      res.render('main',{layout:'index', title: "Astra | Register"});
  }
  else {
      // user shouldn't be able to register when already logged in
      res.redirect("/");
  }
});

router.get('/bookings',function (req,res) {
  /*only go to the bookings page if the user is logged in and they have
   entered a query i.e localhost:8080/bookings.html wouldn't work on its own
  */
  res = df.setResponseHeader(req, res);

  if(req.session.loggedin){
      if(!isEmpty(req.query)){
        res.render('main', {layout:'index', title:  "Astra | Bookings"});
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

router.post('/confirmation',function (req,res) {
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

router.post('/confirmed', function(req,res) {
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
  }
});

router.post('/login',function(req,res) {
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

router.get('/session', function(req, res) {
  res.send({isLoggedIn: req.session.loggedin, isAdmin: req.session.isAdmin === 1});
});

router.post('/registered',function(req,res){
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
      }
  }
  else {
      res.redirect('/');
  }
});


router.get('/logout',function (req,res) {
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

module.exports = router;