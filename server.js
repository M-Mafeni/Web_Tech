"use strict";
const express = require('express');
const exphbs  = require('express-handlebars');
const app = express();
const app1 = express(); //for http server
const session = require('express-session');
const port = 8080;
const secure_port = 3000;

const fs = require('fs');
const http = require('http');
const https = require('https');
const router = require("./routes");

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
http.createServer(app1).listen(port,() => console.log(`listening on port ${port}!`));
// redirect all http requests to https server
app1.all('*',function(req,res){
    res.redirect('https://localhost:3000'+req.url);
});

https.createServer({
    key: fs.readFileSync('server.key'),
    cert: fs.readFileSync('server.cert')
},app)
.listen(secure_port,() => console.log(`listening on port ${secure_port}! \n Go to https://localhost:3000`));

app.use("/", router);
