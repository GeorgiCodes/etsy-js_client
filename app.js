var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var url = require('url');
var nconf = require('nconf');
var etsyjs = require('etsy-js');

// nconf reads in config values from json file
nconf.argv().env();
nconf.file({ file: 'config.json' });

client = etsyjs.client({
  key: nconf.get('key'),
  secret: nconf.get('secret'),
  callbackURL: 'http://localhost:3000/authorize'
});

// init app with sessions
var app = express();
app.use(cookieParser('secEtsy'));
app.use(session());
//
// app.get('/', function(req, res) {
//   var oauthSession = {token: req.session.token, secret: req.session.sec};
//
//   client.requestToken(function(err, response) {
//     req.session.token = response.token;
//     req.session.sec = response.tokenSecret;
//     res.redirect(response.loginUrl);
//   });
// }
//
// app.get('/authorize', function(req, res) {
//   var query = url.parse(req.url, true).query; // parse query paramaters for verifier
//   var verifier = query.oauth_verifier;
//
//   client.accessToken(req.session.token, req.session.sec, verifier, function(err, response) {
//     req.session.token = response.token;
//     req.session.sec = response.tokenSecret;
//     res.redirect('/');
//   });
// });
//
// var server = app.listen(3000, function() {
//   console.log('Listening on port %d', server.address().port);
// });
