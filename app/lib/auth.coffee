mongo = glob.mongo
redis = glob.redis
session = {}
twitter = {}

glob.modules.everyauth.facebook
    .appId(glob.config.facebook.key)
    .appSecret(glob.config.facebook.secret)
    .moduleTimeout(20000)
    .scope('email')  
    .fields('id,name,email,first_name,last_name') 
    .handleAuthCallbackError((req, res) ->
        console.log 'handleError'
    ).findOrCreateUser((session, accessToken, accessTokExtra, fbUserMetadata) ->
        promise = this.Promise()
        glob.mongo.user.findOne {facebookId: fbUserMetadata.id}, (err,user)->
            console.log err if err
            user = new glob.mongo.user() unless user
            user.facebookId = fbUserMetadata.id
            user.facebookName = fbUserMetadata.first_name + ' ' + fbUserMetadata.last_name
            user.email = fbUserMetadata.email
            user.facebookToken = accessToken
            user.name = user.facebookName unless user.name
            user.save (err)->
                console.log err if err
            session.user = user
            promise.fulfill user
        return promise
    ).redirectPath "/"

glob.modules.everyauth.twitter
    .consumerKey(glob.config.twitter.key)
    .consumerSecret(glob.config.twitter.secret)
    .moduleTimeout(20000)
    .findOrCreateUser((session, accessToken, accessTokenSecret, twitterUserMetadata) ->
        promise = this.Promise()
        glob.mongo.user.findOne {twitterId: twitterUserMetadata.id}, (err,user)->
            console.log err if err
            user = new glob.mongo.user() unless user
            user.twitterId = twitterUserMetadata.id
            user.twitterName = twitterUserMetadata.name
            user.twitterToken = accessToken
            user.twitterSecret = accessTokenSecret
            user.name = user.twitterName unless user.name
            user.save (err)->
                console.log err if err
            session.user = user
            promise.fulfill user
        return promise
    ).redirectPath "/"

glob.modules.everyauth.linkedin
    .consumerKey(glob.config.linkedin.key)
    .consumerSecret(glob.config.linkedin.secret)
    .moduleTimeout(20000)
    .findOrCreateUser((session, accessToken, accessTokenSecret, linkedinUserMetadata) ->
        promise = this.Promise()
        glob.mongo.user.findOne {linkedinId: linkedinUserMetadata.id}, (err,user)->
            console.log err if err
            user = new glob.mongo.user() unless user
            user.linkedinId = linkedinUserMetadata.id
            user.linkedinName = linkedinUserMetadata.firstName + ' ' + linkedinUserMetadata.lastName
            user.linkedinToken = accessToken
            user.linkedinSecret = accessTokenSecret
            user.name = user.linkedinName unless user.name
            user.save (err)->
                console.log err if err
            session.user = user
            promise.fulfill user
        return promise
    ).redirectPath "/"

glob.modules.everyauth.everymodule.findUserById (userId, cb)->
    glob.mongo.user.findById userId, cb

exports.check = (req, res, next) ->
    console.log req.session
    console.log req.user
    next()
    return
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

session.start = (req, res, next) ->
    req.session =
        name: req.user.name or req.user.email or req.user.facebookName or req.user.twitterName
        userAgent: req.headers["user-agent"]
        partner: ''
        teacher: req.user.teacher
    if req.session.name.match glob.var.emailRegExp then req.session.name = req.session.name.split('@')[0]
    req.session.name = req.session.name.replace(/\ /g,'_')
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

module.exports.session = session
