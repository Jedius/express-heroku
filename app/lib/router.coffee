app = glob.app

validate = glob.validate
auth = glob.auth
render = {}
ajax = {}
redirect = {}
room = {}

validate = {}
validate.sign = (req,res,next)->
    req.errors = []
    unless req.query.email and req.query.password 
        return res.send errors: ['incomplite request']
    else unless req.query.email.match /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
        req.errors.push ['email','invalid']
    if req.query.password.length <= 6
        req.errors.push ['password','too short']
    else if req.query.password.length > 30
        req.errors.push ['password','too long password']
    if req.errors.length > 0
        return res.send errors: req.errors
    else
        next()

signUp = (req,res,next)->
    return next() if req.session.user
    glob.mongo.user.findOne {email: req.query.email}, (err,user)->
        if err
            console.log err
            res.send errors: [['server','mongo.user err']]
        else if user
            if user.password is glob.crypt req.query.password
                user.access.push new Date()
                user.save()
                req.session.user = user
                next()
            else
                res.send errors: [['email','email already exist']]
        else
            user = new glob.mongo.user
                email: req.query.email
                password: glob.crypt(req.query.password)
                name: req.query.email.split('@')[0]
            req.session.user = user
            req.sign = true
            next()
            user.save (err)->
                console.error err if err

signIn = (req,res,next)->
    glob.mongo.user.findOne {email: req.query.email, password: glob.crypt(req.query.password)}, (err,user)->
        if err
            console.log err
            res.send errors: [['server','mongo.user err']]
        else unless user
            res.send errors: [['email','wrong combination'], ['password','wrong combination']]
        else
            user.save()
            req.session.user = user
            next()

redirect = (req,res)->
        res.render 'index',
        title: 'babyCarrot'
        session: req.session

app.get '/', (req,res)->
    glob.modules.fs.createWriteStream('access.log', {'flags': 'a'}).end new Date() + ' : ' + (req.headers["x-forwarded-for"] or req.connection.remoteAddress) + '\n'
    req.session.redirect = req.query.redirect if req.query.redirect
    if req.session.user
        redirect req,res
    else
        res.render 'auth',
            title: 'auth'
            error: null

app.get '/auth/signUp', validate.sign, signUp, redirect
app.get '/auth/signIn', validate.sign, signIn, redirect

app.get '/logout', (req,res)->
    req.session.destroy (err)->
        console.log err if err
        res.redirect '/'
