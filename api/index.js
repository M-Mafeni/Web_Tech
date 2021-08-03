let express = require('express');
let router = express.Router();
const df = require('../helper');
const destination = require("./destination");

router.use("/destination", destination);

module.exports = router;