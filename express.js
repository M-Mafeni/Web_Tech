"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const api = require('./api');
const app = express();
const port = 8080;
let OK = 200, NotFound = 404, BadType = 415, Error = 500;

app.set('views', './views');
app.set('view engine', 'hbs');
app.set('view engine', 'handlebars');

app.engine('handlebars', exphbs({
    layoutsDir: __dirname + '/views/layouts'
}));
app.use(express.static('public'));
//app.use(express.static('views'));

//app.use(api);
app.get('/',function (req,res) {
    res.render('main',{layout:'index'});
});

app.get('/bookings.html',function (req,res) {
    let sql = "SELECT * FROM Ticket";
    api.db.all(sql,[],(err,tickets) => {
        if(err){
            throw err;
        }
        res.render('main',{layout:'bookings',
                   tickets: tickets  });
    });
;
});
app.listen(port, () => console.log(`listening on port ${port}!`));
