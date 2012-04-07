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

glob.config = 
    app: 
        name: 'appName'
        protocol: 'http://'
        port: process.env.PORT or 4500
        sessionTime: 3*60*60, #sec
        secretString: 'anySecretString'
    deployEnv: process.env.DEPLOY_ENV or 'dev'
    redisURL: glob.modules.url.parse process.env.REDISTOGO_URL or 'redis://localhost:6379'
    mongoURL: process.env.MONGOHQ_URL or 'mongodb://localhost/dbName'
    twitter: 
        key: 'JLCGyLzuOK1BjnKPKGyQ'
        secret: 'GNqKfPqtzOcsCtFbGTMqinoATHvBcy1nzCTimeA9M0'
    facebook: 
        key: '111565172259433'

glob.var = 
    monthNames: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]


glob.modules.mongoose.connect glob.config.mongoURL
glob.mongo = require './lib/mongo'

glob.redis = glob.modules.redis.createClient glob.config.redisURL.port, glob.config.redisURL.hostname
if glob.config.redisURL.auth then glob.redis.auth glob.config.redisURL.auth.split(":")[1]

glob.crypt = (str)->
  @cipher = glob.modules.crypto.createCipher 'aes-256-cbc',glob.config.app.secretString
  @cipher.update str,'utf8','hex'
  @cipher.final 'hex'

glob.decrypt = (str)->
  @decipher = glob.modules.crypto.createDecipher 'aes-256-cbc',glob.config.app.secretString
  @decipher.update str,'hex','utf8'
  @decipher.final 'utf8'

glob.log = (msg)->
    console.log new Date(),msg

glob.app = app = express.createServer()

app.configure ->
    app.set "views", __dirname + '/views'
    app.set "view engine", "jade"
    app.use express.bodyParser()
    app.use express.cookieParser()
    app.use express.methodOverride()
    app.use app.router
    app.use express.static __dirname + '/public'
    app.use require('connect-assets') src: __dirname + '/assets'

app.configure "development", ->
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true

app.configure "production", ->
    app.use express.errorHandler()


require './lib/router'
app.listen glob.config.app.port

console.log 'Server start on port %d in %s mode', app.address().port, app.settings.env
