express = require('express')
session = require('express-session')
cookieParser = require('cookie-parser')
url = require('url')
nconf = require('nconf')
etsyjs = require('etsy-js')

# nconf reads in config values from json file
nconf.argv().env()
nconf.file({ file: 'config.json' })

# instantiate client with key and secret and set callback url
client = etsyjs.client
  key: nconf.get('key')
  secret: nconf.get('secret')
  callbackURL: 'http://localhost:3000/authorise'

app = express()
app.use(cookieParser('secEtsy'))
app.use(session())

app.get '/', (req, res) ->
  client.requestToken (err, response) ->
    return console.log err if err
    req.session.token = response.token
    req.session.sec = response.tokenSecret
    res.redirect response.loginUrl

app.get '/authorise', (req, res) ->
  # parse the query string for OAuth verifier
  query = url.parse(req.url, true).query;
  verifier = query.oauth_verifier

  # final part of OAuth dance, request access token and secret with given verifier
  client.accessToken req.session.token, req.session.sec, verifier, (err, response) ->
    # update our session with OAuth token and secret
    req.session.token = response.token
    req.session.sec = response.tokenSecret
    res.redirect '/find'

app.get '/find', (req, res) ->
  # we now have OAuth credentials for this session and can perform authenticated requests
  client.auth(req.session.token, req.session.sec).user("etsyjs").find (err, body, headers) ->
    console.log err if err
    console.dir(body) if body
    res.send body.results[0] if body

server = app.listen 3000, ->
  console.log 'Listening on port %d', server.address().port
