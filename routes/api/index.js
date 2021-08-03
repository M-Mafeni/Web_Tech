let express = require('express');
let router = express.Router();
const destination = require("./destination");

router.use("/destination", destination);

module.exports = router;