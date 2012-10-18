global.glob = {}

glob.modules = 
    http: require 'http'
    url: require "url"
    fs: fs = require 'fs'
    qs: require 'querystring'
    child_process: require 'child_process'
    us: require 'underscore'
    express: express = require 'express'
    mongoose: require 'mongoose'
    redis: require 'redis'
    async: require 'async'
    crypto: require 'crypto'
    jade: require 'jade'
    oauth: require 'oauth'
    everyauth: require 'everyauth'

glob.config = require '../config.coffee'

glob.var = 
    monthNames: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]

glob.modules.mongoose.connect glob.config.mongoURL
glob.mongo = require './lib/mongo'

glob.redis = glob.modules.redis.createClient glob.config.redisURL.port, glob.config.redisURL.hostname
if glob.config.redisURL.auth then glob.redis.auth glob.config.redisURL.auth.split(":")[1]

glob.crypt = (str)->
  cipher = glob.modules.crypto.createCipher 'aes-256-cbc',glob.config.app.secretString
  crypted = cipher.update str,'utf8','hex'
  crypted += cipher.final 'hex'

glob.decrypt = (str)->
  decipher = glob.modules.crypto.createDecipher 'aes-256-cbc',glob.config.app.secretString
  decrypted = decipher.update str,'hex','utf8'
  decrypted += decipher.final 'utf8'

glob.log = (msg)->
    console.log new Date(),msg

sessionStore = require('connect-redis')(express)
glob.sessionStore = new sessionStore {client: glob.redis}

glob.app = app = express.createServer()

glob.auth = require './lib/auth'

app.configure ->
    app.set "views", __dirname + '/views'
    app.set "view engine", "jade"
    app.use express.static __dirname + '/assets'
    app.use require('connect-assets') src: __dirname + '/assets'
    app.use express.bodyParser()
    app.use express.cookieParser()
    app.use express.session 
        secret: glob.config.app.secretString
        store: glob.sessionStore
        cookie: 
            maxAge: glob.config.app.maxAge
    app.use express.methodOverride()
    app.use app.router
    app.use glob.modules.everyauth.middleware()    

app.configure "development", ->
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true

app.configure "production", ->
    app.use express.errorHandler()

require './lib/router'

app.listen glob.config.app.port

console.log 'Server start on port %d in %s mode', app.address().port, app.settings.env
#console.log glob.config
