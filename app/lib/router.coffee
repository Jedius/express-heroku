app = glob.app

validate = require './validate'
auth = require './auth'
render = {}
ajax = {}
redirect = {}

render.index = (req,res)->
    if req.session.id
        res.header 'Set-Cookie', 'sid='+req.session.id+'; path=/'+'; expires='+new Date(new Date().getTime()+glob.config.app.sessionTime*1000).toUTCString()
        res.render 'content',
            title: 'title'
            name: req.session.name
    else 
        res.header 'Set-Cookie', 'sid=; path=/; expires='+new Date(0).toUTCString()
        res.render 'auth',
            title: 'hi here'
    console.log req.errors if req.errors.length > 0

ajax.index = (req,res)->
    if req.session.id
        res.header 'Set-Cookie', 'sid='+req.session.id+'; path=/'+'; expires='+new Date(new Date().getTime()+glob.config.app.sessionTime*1000).toUTCString()
        res.partial 'content',
            title: 'title'
            name: req.session.name
    else 
        res.header 'Set-Cookie', 'sid=; path=/; expires='+new Date(0).toUTCString()
        res.partial 'auth',
            title: 'hi here'
    console.log req.errors if req.errors.length > 0

redirect.index = (req,res)->
    res.header 'Set-Cookie', 'sid='+req.session.id+'; path=/'+'; expires='+new Date(new Date().getTime()+glob.config.app.sessionTime*1000).toUTCString()
    res.redirect '/'

app.get '/', auth.check, render.index

app.get '/ajax/auth/signUp', validate.sign, auth.signUp, auth.session.start, ajax.index
app.get '/ajax/auth/signIn', validate.sign, auth.signIn, auth.session.start, ajax.index
app.get '/ajax/auth/facebook', validate.facebook, auth.facebook, auth.session.start, ajax.index
app.get '/ajax/auth/twitter', auth.twitter.start
app.get '/auth/twitter/callback', validate.twitter, auth.twitter.callback, auth.session.start, redirect.index

app.get '/ajax/auth/logout', auth.check, auth.session.stop, ajax.index
