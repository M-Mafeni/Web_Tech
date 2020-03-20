"use strict";
const express = require('express');
const app = express();
const port = 8080;

start();

function start() {
    app.use(express.static('public'));
    app.get('/bookings.html',function (req,res) {
        console.log("received");
        // res.sendFile('bookings.html');
    });
    app.listen(port, () => console.log(`listening on port ${port}!`));
}
