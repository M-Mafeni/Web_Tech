let express = require('express');
let router = express.Router();
const destination = require("./destination");
const bookings = require("./bookings");
const user = require("./user");


router.use("/destination", destination);
router.use("/bookings", bookings);
router.use("/user", user);

module.exports = router;