mongo = glob.mongo
redis = glob.redis
session = {}
twitter = {}

exports.check = (req, res, next) ->
    req.session = {}
    req.errors = {}
    req.cookies.sid = req.query.sid if req.query.sid
    if !req.cookies.sid 
        req.session.err = 'empty cookies'
        return next()
    redis.get "session:" + req.cookies.sid, (err, reply) ->
        if err
            req.errors.db = err
            return next()
        if !reply
            req.errors.db = 'session not found'
            return next()
        req.session = JSON.parse(reply)
        if req.headers['user-agent'] isnt req.session.userAgent
            req.errors.session = 'wrong user-agent'
            return next()
        req.session.id = req.cookies.sid
        next()
        redis.expire 'session:' + req.session.id, glob.config.app.sessionTime

exports.signUp = (req,res,next)->
    mongo.user.findOne {email: req.query.email}, (err, user) ->
        if err
            console.error err
            return res.send errors: {db: 'db error'}
        if user
            mongo.user.findOne {email: req.query.email, password: glob.crypt(req.query.password)}, (err,user)->
                if err
                    console.error err
                    return res.send errors: {db: 'db error'}
                if user
                    req.user = user
                    return next()
                else
                    return res.send errors: {exist: 'email already exist'}
        else
            user = new mongo.user
            user.email = req.query.email
            user.password = glob.crypt(req.query.password)
            user.save (err)->
                console.error err if err
            req.user = user
            next()

exports.signIn = (req,res,next)->
    mongo.user.findOne {email: req.query.email, password: glob.crypt(req.query.password)}, (err, user)->
        if err
            console.error err
            return res.send errors: {db: 'db error'}
        unless user
            console.log 'wrong combination for '+req.query.email
            return res.send errors: {combination: 'wrong'}
        req.user = user
        next()

exports.facebook = (req,res,next)->
    req.oa = new glob.modules.oauth.OAuth2 glob.config.facebook.key, glob.config.facebook.secret, "https://graph.facebook.com", "/dialog/oauth"
    req.oa.get "https://graph.facebook.com/me", req.query.token, (err, data)->
        if err
            console.error err
            return res.send errors: {oa: 'oa error'}
        unless data
            console.error 'oauth facebook no data'
            return res.send errors: {oa: 'oa error'}
        req.fbData = JSON.parse data
        mongo.user.findOne {facebookId: req.fbData.id} , (err, user)->
            if err
                console.error err
                return res.send errors: {db: 'db error'}
            unless user
                user = new mongo.user
                  facebookId: req.fbData.id
                  facebookName: req.fbData.name
                user.save (err)->
                    console.error err if err
            req.user = user
            req.tokens = req.query.token
            next()

twitter.init = (req) ->
    new glob.modules.oauth.OAuth("https://twitter.com/oauth/request_token", "https://twitter.com/oauth/access_token", glob.config.twitter.key, glob.config.twitter.secret, "1.0", "http://" + req.headers.host + "/auth/twitter/callback", "HMAC-SHA1")

twitter.start = (req,res,next)->
    twitter.init(req).getOAuthRequestToken (err, token, secret, results) ->
        if err
            console.error err
            return res.send errors: {oa: 'oa error'}
        unless token and secret
            console.error 'twitter oa: token/secret not exist'
            return res.send errors: {oa: 'oa error'}
        redis.set 'token:twitter:'+token, secret
        res.send redirect: 'https://twitter.com/oauth/authenticate?oauth_token='+token

twitter.callback = (req, res, next) ->
    redis.get "token:twitter:" + req.query.oauth_token, (err, secret) ->
        if err
            console.error err
            return res.send errors: {db: 'db error'}
        unless secret
            console.error 'token not found'
            return res.send errors: {request: 'token not found'}
        redis.del "token:twitter:" + req.query.oauth_token
        twitter.init(req).getOAuthAccessToken req.query.oauth_token, secret, req.query.oauth_verifier, (err, access_token, access_secret, results) ->
            if err
                console.error err
                return res.send errors: {oa: 'oa error'}
            unless access_token and access_secret and results
                console.error 'oa twitter error'
                return res.send errors: {oa: 'oa error'}
            mongo.user.findOne {twitterId: results.user_id}, (err, user) ->
                if err
                    console.error err
                    return res.send errors: {db: 'db error'}
                unless user
                    user = new mongo.user
                        twitterId: results.user_id
                        twitterName: results.screen_name
                    user.save (err)->
                        console.error err if err
                req.user = user
                req.tokens = 
                    token: access_token
                    secret: access_secret
                next()

session.start = (req, res, next) ->
    req.session =
        name: req.user.email or req.user.facebookName or "@" + req.user.twitterName
        userAgent: req.headers["user-agent"]
    req.session.tokens = req.tokens if req.tokens
    redis.set "session:" + req.user._id, JSON.stringify(req.session)
    redis.expire "session:" + req.user._id, glob.config.app.sessionTime
    req.session.id = req.user._id
    next()

session.stop = (req,res,next) ->
    console.error req.errors if req.errors.length > 0
    if req.session.id
        redis.del "session:" + req.session.id if req.session.id.length > 10
        req.session.id = null
    next()

module.exports.twitter = twitter
module.exports.session = session
