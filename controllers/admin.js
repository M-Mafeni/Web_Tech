"use strict";
let express = require('express');
let router = express.Router();
const df = require('../helper');
// const sqlite = require('sqlite3').verbose();
const xhtml = 'application/xhtml+xml';
const utf8 = 'utf-8';
// let db = new sqlite.Database('./astra.db');
const database = require('../database');
let db = database.db;
let OK = 200, UNAUTHORISED = 401;

router.get('/',function(req,res){
    res = df.setResponseHeader(req, res);

    if(req.session.loggedin){
        if(req.session.isAdmin){
            let sql = "SELECT name FROM Destination";
            db.all(sql,[],(err,destinations)=>{
                    let prompt = req.session.prompt;
                    let result = req.session.result;
                    req.session.prompt = null;
                    req.session.result = null;
                    res.render('main',{layout:'admin/add_tickets',loggedin:req.session.loggedin,isAdmin:req.session.isAdmin,isAdminPage:true,destinations:destinations,prompt:prompt,result:result});
            });
        }else{
            res.status(UNAUTHORISED).send('Access Denied');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }

});
router.post('/addticket',function(req,res){
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
            let insertTicketSQL = "INSERT INTO Ticket(origin_date,origin_id,destination_date,destination_id,price) VALUES (datetime(?),?,datetime(?),?,?)";
            let id_sql = "SELECT t1.id AS o_id, t2.id AS d_id FROM  Destination as t1 INNER JOIN Destination as t2 WHERE t1.name = ? AND t2.name = ?"
            //get destination IDs
            db.get(id_sql, [origin,destination],(err,ids)=>{
                if(ids!== undefined){
                    let o_id = ids.o_id;
                    let d_id = ids.d_id;
                    db.run(insertTicketSQL,[o_date_time,o_id,d_date_time,d_id,price],function(err){
                        if(err){
                            req.session.prompt = 'Invalid Price/Invalid Dates';
                            req.session.result = 'prompt-fail';
                        }else{
                            req.session.prompt = 'Ticket added.';
                            req.session.result = 'prompt-success';
                        }
                        res.redirect('/admin');
                    });
                }else{
                    req.session.prompt = 'Destination not valid';
                    req.session.result = 'prompt-fail';
                    res.redirect('/admin');
                }
            });
        }else{
            res.status(UNAUTHORISED).send('Access Denied');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
router.post('/destination',function(req,res){
    if(req.session.loggedin){
        if(req.session.isAdmin){
            let name = req.body.destination;
            let sql = "INSERT INTO Destination(name) VALUES(?)";
            db.run(sql,[name],function(err){
                if(!err){
                    req.session.prompt = 'New destination added.';
                    req.session.result = 'prompt-success';
                }else{
                    req.session.prompt = 'Destination already exists.';
                    req.session.result = 'prompt-fail';
                }
                res.redirect('/admin');
            });
        }else{
            res.status(UNAUTHORISED).send('Access Denied');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
router.get('/tickets',function(req,res){
    res = df.setResponseHeader(req, res);

    if(req.session.loggedin){
        if(req.session.isAdmin){
            //get all tickets
            // let sql = "SELECT * FROM Ticket ORDER BY origin_date DESC";
            let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
            +   "date(destination_date) AS d_date,time(destination_date) as d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
            +   "FROM Ticket ORDER BY origin_date DESC";
            db.all(sql,[],(err,tickets)=>{
                tickets = df.formatTickets(tickets);
                res.render('main',{layout:'admin/edit_tickets',loggedin:req.session.loggedin,isAdmin:req.session.isAdmin,isAdminPage:true,tickets:tickets});
            });
        }else{
            res.status(UNAUTHORISED).send('Access Denied');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
router.get('/tickets/:id',function(req,res){
    res = df.setResponseHeader(req, res);

    if(req.session.loggedin){
        if(req.session.isAdmin){
            let id = req.params.id;
            let sql = "SELECT id, date(origin_date) AS o_date,time(origin_date) as o_time,(SELECT name FROM Destination Where Destination.id = Ticket.origin_id) AS origin_place,"
            +   "date(destination_date) AS d_date,time(destination_date) as d_time,(SELECT name FROM Destination Where Destination.id = Ticket.destination_id) AS destination_place,price "
            +   "FROM Ticket WHERE id = ?";
            db.get(sql,[id],function(err,ticket){
                if(!err){
                    res.render('main',{layout:'admin/update_ticket',loggedin:req.session.loggedin,isAdmin:req.session.isAdmin,isAdminPage:true,ticket:ticket});
                }else{
                    throw err;
                }
            });
        }else{
            res.status(UNAUTHORISED).send('Access Denied');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }
});
router.post('/tickets/:id',function(req,res){
    if(req.session.loggedin && req.session.isAdmin){
        let id = req.params.id;
        let origin = req.body.origin;
        let destination = req.body.destination;
        let o_date = req.body.outbound_date;
        let o_time = req.body.outbound_time;
        let o_date_time = o_date + " " + o_time;
        let d_date = req.body.inbound_date;
        let d_time = req.body.inbound_time;
        let d_date_time = d_date + " " + d_time;
        let price = req.body.price;
        let id_sql = "SELECT t1.id AS o_id, t2.id AS d_id FROM  Destination as t1 INNER JOIN Destination as t2 WHERE t1.name = ? AND t2.name = ?"
        let sql = "UPDATE Ticket SET origin_date = datetime(?), origin_id = ?, "
                  + "destination_date = datetime(?), destination_id = ?, price = ? "
                  + "WHERE id = ?";
        db.get(id_sql, [origin,destination],(err,ids)=>{
            if(!err){
                if(ids !== undefined){
                    let o_id = ids.o_id;
                    let d_id = ids.d_id;
                    db.run(sql,[o_date_time,o_id,d_date_time,d_id,price,id],function(err){
                        if(err){
                            console.log(err);
                        }else{
                            res.redirect('/admin/tickets');
                        }
                    });
                }else{
                    console.log('names not defined');
                }
            }else{
                console.log(err);
            }
        });
        // db.get(sql,[])
    }else{
        res.status(UNAUTHORISED).send('Access Denied');
    }
});
router.delete('/tickets/:id',function(req,res){
    if(req.session.loggedin && req.session.isAdmin){
        let id = req.params.id;
        let sql = "DELETE FROM Ticket WHERE id = ?";
        db.run(sql ,[id],function(err){
            if(!err){
                res.status(OK);
                //sending url redirection happens on client side
                res.send('Ticket Deleted');
            }else{
                res.status(400);
                res.send(err);
            }
        });
    }else{
        res.status(UNAUTHORISED).send('Access Denied');
    }
});
router.get('/add_admins',function(req,res){
    res = df.setResponseHeader(req, res);
    if(req.session.loggedin){
        if(req.session.isAdmin){
            //get all users who aren't admins
            let sql = "SELECT * FROM User WHERE isAdmin = 0";
            db.all(sql,[],function (err,users) {
                users.forEach((user, i) => {
                    user.full_name = user.first_name + ' ' + user.last_name;
                });
                let prompt = req.session.prompt;
                let result = req.session.result;
                req.session.prompt = null;
                req.session.result = null;
                res.render('main',{layout:'admin/add_admins',loggedin:req.session.loggedin,users:users,prompt:prompt,result:result,isAdmin:req.session.isAdmin});
            });
        }else{
            res.status(UNAUTHORISED).send('Access Denied');
        }
    }else{
        req.session.prompt = 'You are not logged in.';
        req.session.result = 'prompt-fail';
        res.redirect('/');
    }


});
router.post('/add_admins',function(req,res){
    if(req.session.loggedin && req.session.isAdmin ){
        let id = req.body.id;
        let sql = "UPDATE User SET isAdmin = 1 WHERE id = ?";
        db.run(sql,[id],function (err) {
            if(err){
                res.status(400).send(err);
            }else{
                req.session.prompt = 'New Admin added.';
                req.session.result = 'prompt-success';
                res.redirect('/admin/add_admins');
            }
        });
    }else{
        res.status(UNAUTHORISED).send('Access Denied');
    }

});
module.exports = router;
