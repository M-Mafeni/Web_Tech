let express = require('express');
let router = express.Router();
const destination = require("./destination");
const bookings = require("./bookings");


router.use("/destination", destination);
router.use("/bookings", bookings);

module.exports = router;