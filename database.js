const sqlite = require('sqlite3').verbose();
let db = new sqlite.Database('./astra.db');
module.exports = {db};
