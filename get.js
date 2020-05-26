// Make a request and print out the response.

var http = require('https');

var params = {
    'host': 'localhost',
    'port': 3000,
    'path': '/',
    'method': 'GET',
    rejectUnauthorized: false,
    // body: JSON.stringify({
    //     destination: 'Tatooine'
    // })
};

var request = http.request(params);
request.on('response', header);
request.end();

function header(response) {
    console.log("Status code:",  response.statusCode);
    response.on("data", body);
}

function body(data) {
    console.log(data.toString());
}
