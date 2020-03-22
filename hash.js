const sqlite = require('sqlite3').verbose();
let db = new sqlite.Database('./astra.db');
const bcrypt = require('bcrypt');
let sql = "SELECT email,password from User"
db.all(sql,[],(err,rows)=>{
    rows.forEach((row)=>{
        let hash = bcrypt.hash(row.password,10,function(err,hash){
            console.log(row.password + " " + hash);
        });
    });
});







db.close();