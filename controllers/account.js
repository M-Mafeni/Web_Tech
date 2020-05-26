"use strict";
let express = require('express');
let router = express.Router();
const df = require('../helper');
const xhtml = 'application/xhtml+xml';
const utf8 = 'utf-8';
const bcrypt = require('bcrypt');
const database = require('../database');
let db = database.db;

router.get('/',function (req,res) {
    res = df.setResponseHeader(req, res);

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

                let prompt = req.session.prompt;
                let result = req.session.result;
                req.session.prompt = null;
                req.session.result = null;
                // let isAccount = true;
                res.render('main',{layout:'account/account',email:req.session.username,
                            first_name: user.first_name, last_name: user.last_name,
                            address: user.Address, purchased_tickets:purchased_tickets,
                            loggedin:req.session.loggedin, prompt:prompt,result:result,
                            isAccount:true, isAdmin:req.session.isAdmin});
            });
        });
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }

});

router.get('/edit',function (req,res) {
    res = df.setResponseHeader(req, res);

    if (req.session.loggedin) {
        let sql = "SELECT * FROM User WHERE email = ?";

        db.get(sql, [req.session.username], (err, user) => {
            let prompt = req.session.prompt;
            let result = req.session.result;
            req.session.prompt = null;
            req.session.result = null;
            res.render('main',{layout:'account/account-edit',email:req.session.username,
                        first_name: user.first_name, last_name: user.last_name,
                        address: user.Address, loggedin:req.session.loggedin, prompt:prompt,result:result,
                        isAdmin:req.session.isAdmin});
        });

    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.post('/edit',function (req,res) {
    if (req.session.loggedin) {
        if(req.body.email != null){
            let passwordSQL = "SELECT password FROM User WHERE email = ?";
            let emailSQL = "SELECT email FROM User WHERE email = ?";
            let updateSQL = "UPDATE User SET email = ?, first_name = ?, last_name = ?, Address = ? "
                    + "WHERE email = ?";

            db.get(passwordSQL, [req.session.username], (err, user2) => {
                bcrypt.compare(req.body.password, user2.password, function(err2,valid) {
                    if (valid) {
                        db.get(emailSQL, [req.body.email], (err4, temp) => {
                            // the email shouldn't already be taken, unless taken by yourself
                            if (temp == undefined || temp.email == req.session.username) {
                                db.run(updateSQL, [req.body.email, req.body.first_name, req.body.last_name, req.body.address, req.session.username], (err3, user) => {
                                    req.session.username = req.body.email;
                                    req.session.prompt = 'Updated successfully.';
                                    req.session.result = 'prompt-success';
                                    res.redirect('/account');
                                });
                            }
                            else {
                                req.session.prompt = 'Email already registered.';
                                req.session.result = 'prompt-fail';
                                res.redirect('/account/edit');
                            }
                        });
                    }
                    else {
                        req.session.prompt = 'Password incorrect.';
                        req.session.result = 'prompt-fail';
                        res.redirect('/account/edit');
                    }
                });

            });
        }
        else {
            res.redirect('/account');
        }

    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.get('/password', function (req,res) {
    res = df.setResponseHeader(req, res);

    if (req.session.loggedin) {
        let prompt = req.session.prompt;
        let result = req.session.result;
        req.session.prompt = null;
        req.session.result = null;
        res.render('main',{layout:'account/account-password', loggedin:req.session.loggedin, prompt:prompt,result:result,
                           isAdmin:req.session.isAdmin});
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.post('/password', function (req,res) {
    if (req.session.loggedin) {
        if(req.body.old_password != null) {
            let getPasswordSQL = "SELECT password FROM User WHERE email = ?";
            let updateSQL = "UPDATE User SET password = ? WHERE email = ?";

            db.get(getPasswordSQL, [req.session.username], (err, user) => {
                bcrypt.compare(req.body.old_password, user.password, function(err2,valid) {
                    if (valid) {
                        if (req.body.new_password == req.body.confirm_password) {
                            bcrypt.hash(req.body.new_password, 10, function(err3, hash) {
                                db.run(updateSQL, [hash, req.session.username], (err4, temp) => {
                                    req.session.prompt = 'Password updated successfully.';
                                    req.session.result = 'prompt-success';
                                    res.redirect('/account');
                                });
                            });
                        }
                        else {
                            req.session.prompt = 'Passwords do not match.';
                            req.session.result = 'prompt-fail';
                            res.redirect('/account/password');
                        }
                    }
                    else {
                        req.session.prompt = 'Password incorrect.';
                        req.session.result = 'prompt-fail';
                        res.redirect('/account/password');
                    }
                });
            });
        }
        else res.redirect('/account');
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.get('/delete',function (req,res) {
    res = df.setResponseHeader(req, res);

    if (req.session.loggedin) {
        let prompt = req.session.prompt;
        let result = req.session.result;
        req.session.prompt = null;
        req.session.result = null;
        res.render('main',{layout:'account/account-delete', loggedin:req.session.loggedin, prompt:prompt,result:result, isAdmin:req.session.isAdmin});
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.post('/delete',function (req,res) {
    if (req.session.loggedin) {
        let idPasswordSQL = "SELECT id, password FROM User WHERE email = ?";
        let userSQL = "DELETE FROM User WHERE id = ?";
        let ticketSQL = "DELETE FROM User_Ticket WHERE user_id = ?";

        db.get(idPasswordSQL, [req.session.username], (err, user) => {
            bcrypt.compare(req.body.password, user.password, function(err2,valid) {
                if (valid) {
                    db.run(userSQL, [user.id], (err2, temp) => {
                        db.run(ticketSQL, [user.id], (err3, temp2) => {
                            req.session.loggedin = false;
                            req.session.username = null;
                            req.session.isAdmin = false;
                            req.session.prompt = 'Account successfully deleted.';
                            req.session.result = 'prompt-success';
                            res.redirect('/');
                        });
                    });
                }
                else {
                    req.session.prompt = 'Password incorrect.';
                    req.session.result = 'prompt-fail';
                    res.redirect('/account/delete');
                }
            });
        });
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.get('/refund/:id', function (req,res) {
    res = df.setResponseHeader(req, res);

    if (req.session.loggedin) {
        let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
        +   "date(destination_date) AS d_date,time(destination_date) as d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
        +   "FROM Ticket WHERE id = ?";

        db.all(sql, [req.params.id], (err, tickets) => {
            tickets.forEach((ticket, i) => {
                ticket.o_date = df.formatDate(ticket.o_date);
                ticket.d_date = df.formatDate(ticket.d_date);
                ticket.o_time = df.formatTime(ticket.o_time);
                ticket.d_time = df.formatTime(ticket.d_time);
            });

            let prompt = req.session.prompt;
            let result = req.session.result;
            req.session.prompt = null;
            req.session.result = null;

            res.render('main',{layout:'account/account-refund', loggedin:req.session.loggedin, prompt:prompt,result:result,
                               isAdmin:req.session.isAdmin, refund_ticket: tickets});
        });
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

router.post('/refund/:id',function (req,res) {
    if (req.session.loggedin) {
        let ticketSQL = "DELETE FROM User_Ticket WHERE id = (SELECT id FROM User_Ticket "
                      + "WHERE user_id = (SELECT id FROM User WHERE email = ?) "
                      + "AND ticket_id = ? LIMIT 1)";

        db.run(ticketSQL, [req.session.username, req.params.id], (err2, temp) => {
            req.session.prompt = 'Ticket successfully refunded.';
            req.session.result = 'prompt-success';
            res.redirect('/account');
        });
    }
    else {
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});

module.exports = router;
