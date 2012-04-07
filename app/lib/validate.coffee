exports.facebook = (req,res,next)->
    req.errors = {}
    unless req.query.token
        return res.send error: 'no token'
    next()

exports.sign = (req,res,next)->
    req.errors = {}
    unless req.query.email and req.query.password 
        return res.send errors: {request: 'incomplete request'}
    unless req.query.email.match /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
        req.errors.email = 'invalid email'
    if req.query.password.length <= 6
        req.errors.password = 'too short password'
    else if req.query.password.length > 30
        req.errors.password = 'too long password'
    if req.errors.length > 0
        res.send errors: req.errors
    else next()

exports.twitter = (req,res,next)->
    unless req.query.oauth_token and req.query.oauth_verifier
        return res.redirect '/'
    next()

